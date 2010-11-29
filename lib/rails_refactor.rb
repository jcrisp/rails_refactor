#!/usr/bin/env ruby
# ./rails_refactor.rb rename DummyController HelloController 
# ./rails_refactor.rb rename DummyController.my_action new_action

require 'config/environment'

class Renamer
  def initialize(from, to)
    @from, @to = from, to

    @from_controller, @from_action = from.split(".")
    @from_resource_name = @from_controller.gsub(/Controller$/, "")
    @from_resource_path = @from_resource_name.underscore
  end

  def replace_in_file(path, find, replace)
    contents = File.read(path)
    contents.gsub!(find, replace)
    File.open(path, "w+") { |f| f.write(contents) }
  end

  def controller_rename
    to_controller_path = "app/controllers/#{@to.underscore}.rb"
    to_resource_name   = @to.gsub(/Controller$/, "")
    to_resource_path   = to_resource_name.underscore

    `mv app/controllers/#{@from.underscore}.rb #{to_controller_path}`
    replace_in_file(to_controller_path, @from, @to)

    to_spec = "spec/controllers/#{to_resource_path}_controller_spec.rb"
    `mv spec/controllers/#{@from.underscore}_spec.rb #{to_spec}`
    replace_in_file(to_spec, @from, @to)

    `mv app/views/#{@from_resource_path} app/views/#{to_resource_path}`

    to_helper_path = "app/helpers/#{to_resource_path}_helper.rb"
    `mv app/helpers/#{@from_resource_path}_helper.rb #{to_helper_path}`

    replace_in_file(to_helper_path, @from_resource_name, to_resource_name)

    replace_in_file('config/routes.rb', @from_resource_path, to_resource_path)
  end

  def controller_action_rename
    controller_path = "app/controllers/#{@from_controller.underscore}.rb"
    replace_in_file(controller_path, @from_action, @to)
    
    views_for_action = "app/views/#{@from_resource_path}/#{@from_action}.*"

    Dir[views_for_action].each do |file|
      extension = file.split('.')[1..2].join('.')
      cmd = "mv #{file} app/views/#{@from_resource_path}/#{@to}.#{extension}"
      `#{cmd}`
    end
  end
end

if ARGV.length == 3
  command, from, to = ARGV
  renamer = Renamer.new(from, to)

  if command == "rename"
    if from.include? '.'
      renamer.controller_action_rename 
    else
      renamer.controller_rename
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

    def renamer(from, to)
      Renamer.new(from, to)
    end

    def controller_action_rename(from, to)
      renamer(from, to).controller_action_rename
    end

    def controller_rename(from, to)
      renamer(from, to).controller_rename
    end

    def assert_file_changed(path, from, to)
      contents = File.read(path)
      assert contents.include?(to) 
      assert !contents.include?(from) 
    end

    def test_controller_action_rename
      controller_action_rename('DummiesController.index', 'new_action')
      assert_file_changed("app/controllers/dummies_controller.rb", "index", "new_action")
      assert File.exists?("app/views/dummies/new_action.html.erb")
      assert !File.exists?("app/views/dummies/index.html.erb")
    end

    def test_controller_rename
      controller_rename("DummiesController", "HelloWorldController")
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
  puts "  rails_refactor.rb rename DummyController HelloController"
  puts "  rails_refactor.rb rename DummyController.my_action new_action"
  puts "  rails_refactor.rb test"
end
