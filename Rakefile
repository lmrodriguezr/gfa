require 'bundler/gem_tasks'
require 'rake/testtask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'gfa/version'

SOURCES = FileList['lib/**/*.rb']

desc 'Default Task'
task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end
