require 'test/unit'
require 'jruby-kafka'
require 'util/producer'

class TestKafkaConsumer < Test::Unit::TestCase
  def test_01_run
    topics = ['test_run']
    options = {
        :bootstrap_servers => '127.0.0.1:9092',
        :key_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer',
        :value_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer',
        :auto_offset_reset => 'earliest',
        :group_id => topics[0],
        :topics => topics
    }
    send_test_messages topics[0]
    queue = SizedQueue.new(20)
    consumer = Kafka::KafkaConsumer.new(options)
    consumer.subscribe
    runner_thread = Thread.new { kafka_consumer_test_blk consumer, queue}
    begin
      timeout(30) do
        until queue.length > 3 do
          sleep 1
          next
        end
        consumer.stop
      end
    end
    runner_thread.join
    found = []
    until queue.empty?
      found << queue.pop
    end
    assert_equal([ "codec gzip test message",
                   "codec none test message",
                   "codec snappy test message",
                   "test message" ],
                 found.map(&:to_s).uniq.sort,)
  end

  def kafka_consumer_test_blk(consumer, queue)
    begin
      while true do
        records = consumer.poll(10000)
        for record in records do
          queue <<  record.value.to_s
        end
      end
    rescue org.apache.kafka.common.errors.WakeupException => e
      raise e unless consumer.stop?
    ensure
      consumer.close
    end
  end
end
