require 'test/unit'
require 'timeout'
require 'jruby-kafka'
require 'util'

class TestKafka < Test::Unit::TestCase
  def send_msg
    producer = Kafka::KafkaProducer.new(KAFKA_PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg('test',nil, nil, 'test message')
  end

  def test_send_message
    future = send_msg
    assert_not_nil(future)
    begin
      timeout(10) do
        until future.isDone() do
          next
        end
      end
    end
    assert(future.isDone(), 'expected message to be done')
    assert(future.get().topic(), 'test')
    assert_equal(future.get().partition(), 0)

  end

  def send_msg_cb(&block)
    producer = Kafka::KafkaProducer.new(KAFKA_PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg('test',nil, nil, 'test message', &block)
  end

  def test_send_msg_with_cb
    metadata = exception = nil
    future = send_msg_cb { |md,e| metadata = md; exception = e }
    assert_not_nil(future)    
    begin
      timeout(10) do
        while metadata.nil? && exception.nil? do
          next
        end
      end
    end
    assert_not_nil(metadata)   
    assert_instance_of(Java::OrgApacheKafkaClientsProducer::RecordMetadata, metadata)
    assert_nil(exception)
    assert(future.isDone(), 'expected message to be done')
  end

  def test_get_sent_msg
    queue = SizedQueue.new(20)
    consumer = Kafka::Consumer.new(CLIENT_OPTIONS)
    send_msg
    streams = consumer.message_streams
    streams.each_with_index do |stream, thread_num|
      Thread.new { consumer_test stream, thread_num, queue}
    end
    sleep 10
    consumer.shutdown
    found = []
    until queue.empty?
      found << queue.pop
    end
    assert(found.include?('test message'), 'expected to find message: test message')
  end

end
