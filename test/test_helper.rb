require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'test/unit'
require 'gfa/common'

def fixture_path(file)
  File.expand_path("../fixtures/#{file}", __FILE__)
end

