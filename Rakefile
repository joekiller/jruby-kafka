task :package do
  system("gem build jruby-kafka.gemspec")
end


task :install do
  Rake::Task["package"].execute
  system("gem install jruby-kafka*.gem")
  Rake::Task["clean"].execute
end

task :clean do
  system("rm jruby*.gem")
end