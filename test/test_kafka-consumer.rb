require 'test/unit'
require 'jruby-kafka'
require 'util/kafka-consumer'
require 'util/kafka-producer'

class TestKafkaConsumer < Test::Unit::TestCase
  def setup
    @topics = ['KafkaConsumer']
  end

  def test_consume_record
    @topics = ['consume_record']
    queue = SizedQueue.new(20)
    consumer = Kafka::KafkaConsumer.new(KAFKA_CONSUMER_OPTIONS)
    begin
      timeout(30) do
        Thread.new { process consumer, queue}
        until queue.length > 0 do
          send_test_messages @topics[0]
          sleep 1
          next
        end
      end
    end
    consumer.close
    found = []
    until queue.empty?
      found << queue.pop
    end
    assert_equal([ "test" ],
                 found.map(&:to_s).uniq.sort,)
  end

  KAFKA_CONSUMER_OPTIONS = {
      :bootstrap_servers => '127.0.0.1:9092',
      :group_id=> 'test',
      :enable_auto_commit => 'true',
      :auto_commit_interval_ms => '1000',
      :session_timeout_ms => '30000',
      :key_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer',
      :value_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer'
  }

  def process(consumer, queue)
    consumer.subscribe(@topics)
    while true
      records = consumer.poll(100, java.util.concurrent.TimeUnit::MILLISECOND)
      records.each do |record|
        queue << record
      end
    end
  end
end