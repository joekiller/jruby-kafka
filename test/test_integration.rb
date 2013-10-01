require "test/unit"

class TestKafka < Test::Unit::TestCase
  def setup
    raise 'Please set KAFKA_PATH' if ENV['KAFKA_PATH'].nil?

    dir = File.join(ENV['KAFKA_PATH'], '/core/target/scala-2.8.0')
    if !File.directory?(dir)
      raise "KAFKA_PATH set, but #{dir} doesn't exist"
    end

    Dir.glob(File.join(dir, '*.jar')).each do |jar|
      require jar
    end

    $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
    require 'jruby-kafka'
  end

  def test_run
    group = Kafka::Group.new('localhost:2181','test','test')
    group.run(1)
  end

end