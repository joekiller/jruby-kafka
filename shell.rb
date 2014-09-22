['/Users/jlawson/rk/kafka/core/target/scala-2.8.0/*.jar'].each do |path|
  Dir.glob(path).each do |jar|
    require jar
  end
end

$:.unshift('lib')

require 'rubygems'
require 'jruby-kafka'