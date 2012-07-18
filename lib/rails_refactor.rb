#!/usr/bin/env ruby
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

begin
  File.exist? './config/environment.rb'
rescue LoadError
  puts "*** rails_refactor needs to be run from the root of a Rails 3 webapp ***"
  exit
end

class Renamer
  def initialize(from, to)
    @from, @to = from, to
  end

  def model_rename
    to_model_file = @to.underscore + ".rb"
    `mv app/models/#{@from.underscore}.rb app/models/#{to_model_file}`
    replace_in_file("app/models/#{to_model_file}", @from, @to)

    to_spec_file = @to.underscore + "_spec.rb"
    `mv spec/models/#{@from.underscore}_spec.rb spec/models/#{to_spec_file}`
    replace_in_file("spec/models/#{to_spec_file}", @from, @to)

    Dir["db/migrate/*_create_#{@from.underscore.pluralize}.rb"].each do |file|
      timestamp_and_path = file.split('_')[0]
      to_migration_path = "#{timestamp_and_path}_create_#{@to.underscore.pluralize}.rb"
      `mv #{file} #{to_migration_path}`
      replace_in_file(to_migration_path, "Create#{@from.pluralize}", "Create#{@to.pluralize}")
      replace_in_file(to_migration_path, @from.underscore.pluralize, @to.underscore.pluralize)
    end
  end

  def controller_rename
    setup_for_controller_rename

    to_controller_path = "app/controllers/#{@to.underscore}.rb"
    to_resource_name   = @to.gsub(/Controller$/, "")
    to_resource_path   = to_resource_name.underscore

    `mv app/controllers/#{@from.underscore}.rb #{to_controller_path}`
    replace_in_file(to_controller_path, @from, @to)

    # TODO: Use cross-platform move commands.
    if File.exist?("spec/controllers/#{@from.underscore}_spec.rb")
      to_spec = "spec/controllers/#{to_resource_path}_controller_spec.rb"
      `mv spec/controllers/#{@from.underscore}_spec.rb #{to_spec}`
      replace_in_file(to_spec, @from, @to)
    end

    if Dir.exist?("app/views/#{@from_resource_path}")
      `mv app/views/#{@from_resource_path} app/views/#{to_resource_path}`
    end

    to_helper_path = "app/helpers/#{to_resource_path}_helper.rb"
    if File.exist?("app/helpers/#{@from_resource_path}_helper.rb")
      `mv app/helpers/#{@from_resource_path}_helper.rb #{to_helper_path}`
      replace_in_file(to_helper_path, @from_resource_name, to_resource_name)
    end

    replace_in_file('config/routes.rb', @from_resource_path, to_resource_path)
  end

  def controller_action_rename
    setup_for_controller_rename
    controller_path = "app/controllers/#{@from_controller.underscore}.rb"
    replace_in_file(controller_path, @from_action, @to)

    views_for_action = "app/views/#{@from_resource_path}/#{@from_action}.*"

    Dir[views_for_action].each do |file|
      extension = file.split('.')[1..2].join('.')
      `mv #{file} app/views/#{@from_resource_path}/#{@to}.#{extension}`
    end
  end

  def setup_for_controller_rename
    @from_controller, @from_action = @from.split(".")
    @from_resource_name = @from_controller.gsub(/Controller$/, "")
    @from_resource_path = @from_resource_name.underscore
  end

  def replace_in_file(path, find, replace)
    contents = File.read(path)
    contents.gsub!(find, replace)
    File.open(path, "w+") { |f| f.write(contents) }
  end

end

if ARGV.length == 3
  command, from, to = ARGV
  renamer = Renamer.new(from, to)

  if command == "rename"
    if from.include? "Controller"
      if from.include? '.'
        renamer.controller_action_rename
      else
        renamer.controller_rename
      end
    else
      renamer.model_rename
    end
  end
elsif ARGV[0] == "test"
  require 'test/unit'
  class RailsRefactorTest < Test::Unit::TestCase

    def setup
      raise "Run tests in 'dummy' rails project" if !Dir.pwd.end_with? "dummy"
    end

    def teardown
      `git checkout .`
      `git clean -f`
      `rm -rf app/views/hello_world`
    end

    def rename(from, to)
      `../lib/rails_refactor.rb rename #{from} #{to}`
    end

    def assert_file_changed(path, from, to)
      contents = File.read(path)
      assert contents.include?(to)
      assert !contents.include?(from)
    end

    def test_model_rename
      rename("DummyModel", "NewModel")

      assert File.exist?("app/models/new_model.rb")
      assert !File.exist?("app/models/dummy_model.rb")
      assert_file_changed("app/models/new_model.rb",
                          "DummyModel", "NewModel")

      assert File.exist?("spec/models/new_model_spec.rb")
      assert !File.exist?("spec/models/dummy_model_spec.rb")
      assert_file_changed("spec/models/new_model_spec.rb",
                          "DummyModel", "NewModel")

      assert File.exist?("db/migrate/20101230081247_create_new_models.rb")
      assert !File.exist?("db/migrate/20101230081247_create_dummy_models.rb")
      assert_file_changed("db/migrate/20101230081247_create_new_models.rb",
                          "CreateDummyModels", "CreateNewModels")
      assert_file_changed("db/migrate/20101230081247_create_new_models.rb",
                          ":dummy_models", ":new_models")
    end

    def test_controller_action_rename
      rename('DummiesController.index', 'new_action')
      assert_file_changed("app/controllers/dummies_controller.rb", "index", "new_action")
      assert File.exists?("app/views/dummies/new_action.html.erb")
      assert !File.exists?("app/views/dummies/index.html.erb")
    end

    def test_controller_rename
      rename("DummiesController", "HelloWorldController")
      assert File.exist?("app/controllers/hello_world_controller.rb")
      assert !File.exist?("app/controllers/dummies_controller.rb")

      assert File.exist?("app/views/hello_world/index.html.erb")
      assert !File.exist?("app/views/dummies/index.html.erb")

      assert_file_changed("app/controllers/hello_world_controller.rb",
                          "DummiesController", "HelloWorldController")

      routes_contents = File.read("config/routes.rb")
      assert routes_contents.include?("hello_world")
      assert !routes_contents.include?("dummies")

      helper_contents = File.read("app/helpers/hello_world_helper.rb")
      assert helper_contents.include?("HelloWorldHelper")
      assert !helper_contents.include?("DummiesHelper")

      assert File.exist?("spec/controllers/hello_world_controller_spec.rb")
      assert !File.exist?("spec/controllers/dummies_controller_spec.rb")
      assert_file_changed("spec/controllers/hello_world_controller_spec.rb",
                          "DummiesController", "HelloWorldController")
    end
  end
else
  puts "Usage:"
  puts "  rails_refactor rename DummyController NewController"
  puts "  rails_refactor rename DummyController.my_action new_action"
  puts "  rails_refactor rename DummyModel NewModel"
end
