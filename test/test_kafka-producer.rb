require 'test/unit'
require 'jruby-kafka'
require 'timeout'

class TestKafka < Test::Unit::TestCase

  def send_msg(topic = 'test')
    options = {
      :bootstrap_servers => 'localhost:9092',
      :key_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
      :value_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
    }
    producer = Kafka::KafkaProducer.new(options)
    producer.connect
    producer.send_msg(topic,nil, nil, 'test message')
  end

  def test_01_send_message
    topic = 'test_send'
    future = send_msg topic
    assert_not_nil(future)
    begin
      timeout(30) do
        until future.isDone() do
          next
        end
      end
    end
    assert(future.isDone(), 'expected message to be done')
  end

  def test_02_get_sent_msg
    topic = 'get_sent_msg'
    send_msg topic
    queue = SizedQueue.new(20)
    options = {
      :zk_connect => 'localhost:2181',
      :group_id => 'test',
      :topic_id => topic,
      :auto_offset_reset => 'smallest'
    }
    group = Kafka::Group.new(options)
    group.run(1,queue)
    begin
      timeout(30) do
        until queue.length > 0 do
          sleep 1
          next
        end
      end
    end
    group.shutdown
    found = []
    until queue.empty?
      found << queue.pop.message.to_s
    end
    assert(found.include?('test message'), 'expected to find message: test message')
  end

end
