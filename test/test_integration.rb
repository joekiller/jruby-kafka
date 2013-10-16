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
    queue = SizedQueue.new(20)
    options = {
        :zk_connect => 'localhost:2181',
        :group_id => 'test',
        :topic_id => 'test',
        :zk_connect_timeout => '10000'
    }
    group = Kafka::Group.new(options)
    puts(group.running?)
    group.run(1,queue)
    Java::JavaLang::Thread.sleep 10000
    puts(group.running?)
    group.shutdown()
    until queue.empty?
      puts(queue.pop)
    end
  end

  def test_from_beginning
    queue = SizedQueue.new(20)
    options = {
        :zk_connect => 'localhost:2181',
        :group_id => 'beginning',
        :topic_id => 'test',
        :reset_beginning => 'from-beginning'
    }
    group = Kafka::Group.new(options)
    group.run(2,queue)
    Java::JavaLang::Thread.sleep 10000
    group.shutdown()
    until queue.empty?
      puts(queue.pop)
    end
  end

end