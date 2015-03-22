require 'test/unit'
require 'timeout'

class TestKafka < Test::Unit::TestCase
  def setup
    $:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
    require 'jruby-kafka'
  end

  def send_msg
    options = {
      :bootstrap_servers => 'localhost:9092',
      :key_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
      :value_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
    }
    producer = Kafka::KafkaProducer.new(options)
    producer.connect
    producer.send_msg('test',nil, nil, 'test message')
  end

  def test_send_message
    future = send_msg
    assert_not_nil(future)
    begin
      timeout(5) do
        until future.isDone() do
          next
        end
      end
    end
    assert(future.isDone(), 'expected message to be done')
  end

  def test_get_sent_msg
    queue = SizedQueue.new(20)
    options = {
        :zk_connect => 'localhost:2181',
        :group_id => 'test',
        :topic_id => 'test'
    }
    group = Kafka::Group.new(options)
    send_msg
    group.run(1,queue)
    group.shutdown
    found = []
    until queue.empty?
      found << queue.pop.message.to_s
    end
    assert(!found.include?('test message'), 'expected to find message: test message')
  end

end
