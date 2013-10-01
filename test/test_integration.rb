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
    options = {
        :zkConnectOpt => 'localhost:2181',
        :groupIdOpt => 'test',
        :topicIdOpt => 'test'
    }
    group = Kafka::Group.new(options)
    group.run(1)
    Java::JavaLang::Thread.sleep 10000
    group.shutdown()
  end

  def test_from_beginning
    options = {
        :zkConnectOpt => 'localhost:2181',
        :groupIdOpt => 'beginning',
        :topicIdOpt => 'test',
        :resetBeginningOpt => 'from-beginning'
    }
    group = Kafka::Group.new(options)
    group.run(3)
    Java::JavaLang::Thread.sleep 10000
    group.shutdown()
  end

end