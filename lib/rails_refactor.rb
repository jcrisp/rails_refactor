#!/usr/bin/env ruby
# ./rails_refactor.rb rename DummyController HelloController 
command, from, to = ARGV
require 'config/environment'

def replace_in_file(path, find, replace)
  contents = File.read(path)
  contents.gsub!(find, replace)
  File.open(path, "w+") { |f| f.write(contents) }
end

def controller_rename(from, to)
  to_controller_path = "app/controllers/#{to.underscore}.rb"
  from_resource_name = from.gsub(/Controller$/, "")
  to_resource_name   = to.gsub(/Controller$/, "")

  from_resource_path = from_resource_name.underscore
  to_resource_path   = to_resource_name.underscore

  `mv app/controllers/#{from.underscore}.rb #{to_controller_path}`
  replace_in_file(to_controller_path, from, to)

  `mv app/views/#{from_resource_path} app/views/#{to_resource_path}`

  to_helper_path = "app/helpers/#{to_resource_path}_helper.rb"
  `mv app/helpers/#{from_resource_path}_helper.rb #{to_helper_path}`

  replace_in_file(to_helper_path, from_resource_name, to_resource_name)

  replace_in_file('config/routes.rb', from_resource_path, to_resource_path)
end

require 'test/unit'
class RailsRefactorTest < Test::Unit::TestCase

  def setup
    `git checkout .`
    `rm -rf app/views/hello_world`
  end

  def test_controller_rename
    controller_rename("DummiesController", "HelloWorldController")
    assert File.exist?("app/controllers/hello_world_controller.rb")
    assert !File.exist?("app/controllers/dummies_controller.rb")

    assert File.exist?("app/views/hello_world/index.html.erb")
    assert !File.exist?("app/views/dummies/index.html.erb")

    controller_contents = File.read("app/controllers/hello_world_controller.rb")
    assert controller_contents.include?("HelloWorldController") 
    assert !controller_contents.include?("DummiesController") 

    routes_contents = File.read("config/routes.rb")
    assert routes_contents.include?("hello_world") 
    assert !routes_contents.include?("dummies") 

    helper_contents = File.read("app/helpers/hello_world_helper.rb")
    assert helper_contents.include?("HelloWorldHelper") 
    assert !helper_contents.include?("DummiesHelper") 

  end
end

