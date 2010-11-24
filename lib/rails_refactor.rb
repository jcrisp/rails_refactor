#!/usr/bin/env ruby
# ./rails_refactor.rb rename DummyController HelloController 
command, from, to = ARGV
require 'config/environment'

def controller_rename(from, to)
  to_controller_path = "app/controllers/#{to.underscore}.rb"
  `mv app/controllers/#{from.underscore}.rb #{to_controller_path}`

  new_controller = File.read(to_controller_path)
  new_controller.gsub!(from, to)
  File.open(to_controller_path, "w+") { |f| f.write(new_controller) }

  # views
  from_view_path = from.gsub(/Controller$/, "").downcase
  to_view_path   = to.gsub(/Controller$/, "").downcase
  `mv app/views/#{from_view_path} app/views/#{to_view_path}`
end

require 'test/unit'
class RailsRefactorTest < Test::Unit::TestCase

  def setup
    `git checkout .`
  end

  def test_controller_rename
    controller_rename("DummiesController", "HelloController")
    assert File.exist?("app/controllers/hello_controller.rb")
    assert !File.exist?("app/controllers/dummies_controller.rb")

    assert File.exist?("app/views/hello/index.html.erb")
    assert !File.exist?("app/views/dummies/index.html.erb")

    controller_contents = File.read("app/controllers/hello_controller.rb")
    assert controller_contents.include?("HelloController") 
    assert !controller_contents.include?("DummiesController") 
  end
end

