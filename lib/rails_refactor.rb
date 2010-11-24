#!/usr/bin/env ruby

# ./rails_refactor.rb rename DummyController HelloController 
`git checkout .`
command, from, to = ARGV
require 'config/environment'
`mv app/controllers/#{from.underscore}.rb app/controllers/#{to.underscore}.rb`
from_view_path = from.gsub(/Controller$/, "").downcase
to_view_path   = to.gsub(/Controller$/, "").downcase
`mv app/views/#{from_view_path} app/views/#{to_view_path}`

puts `git status`
