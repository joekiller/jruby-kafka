require 'maven/ruby/tasks'
require 'jar_installer'

task :default

desc 'setup jar dependencies to be used for "testing" and generates jruby-kafka_jars.rb'
task :setup do
  Jars::JarInstaller.install_jars
end

task :jar do
  Maven::Ruby::Maven.new.exec 'prepare-package'
end

task :package do
  system('gem build jruby-kafka.gemspec')
end

task :publish do
  Rake::Task['clean'].execute
  Rake::Task['package'].execute
  system('gem push jruby-kafka*.gem')
end


task :install do
  Rake::Task['package'].execute
  system('gem install jruby-kafka*.gem')
  Rake::Task['clean'].execute
end

task :clean do
  system('rm jruby*.gem')
end
