begin
  require 'bundler/gem_tasks'
rescue LoadError
  puts "Ruby >= 1.9 required for build tasks"
end

require 'rake/testtask'

task :default => :test

desc "Run basic tests"
Rake::TestTask.new("test") { |t| t.pattern = 'test/*_test.rb' }
