require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['lib', 'test', 'test/util/*']
end

desc "Run tests"
task :default => :test


require 'jars/installer'
task :install_jars do
  Jars::Installer.vendor_jars!
end
