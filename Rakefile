require 'rubygems/package_task'
Gem::PackageTask.new( eval File.read( 'jruby-kafka.gemspec' ) ) do
  desc 'Pack gem'
  task :package
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['lib', 'test']
end

desc "Run tests"
task :default => :test


require 'ruby-maven'
desc "Pack jar after compiling classes"
task :compile do
  RubyMaven.exec('prepare-package')
end
