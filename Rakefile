require 'maven/ruby/tasks'

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