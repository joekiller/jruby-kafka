require 'test/unit'
require 'jruby-kafka'
require 'util'

class TestKafka < Test::Unit::TestCase

  def send_msg
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg('test',nil, 'test message')
  end

  def send_msg_deprecated
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.sendMsg('test',nil, 'test message')
  end

  def producer_compression_send(compression_codec='none')
    options = PRODUCER_OPTIONS.clone
    options[:compression_codec] = compression_codec
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.send_msg('test',nil, "codec #{compression_codec} test message")
  end

  def send_compression_none
    producer_compression_send('none')
  end

  def send_compression_gzip
    producer_compression_send('gzip')
  end

  def send_compression_snappy
    #snappy test may fail on mac, see https://code.google.com/p/snappy-java/issues/detail?id=39
    producer_compression_send('snappy')
  end

  def send_test_messages
    send_compression_none
    send_compression_gzip
    send_compression_snappy
    send_msg
  end

  def test_run
    queue = SizedQueue.new(20)
    send_test_messages
    consumer = Kafka::Consumer.new(CLIENT_OPTIONS)
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
    assert_equal([ "codec gzip test message",
                   "codec none test message",
                   "codec snappy test message",
                   "test message" ],
                 found.map(&:to_s).uniq.sort,)
  end

  def test_from_beginning
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'beginning',
      :topic => 'test',
      :reset_beginning => 'from-beginning',
      :auto_offset_reset => 'smallest'
    }
    consumer = Kafka::Consumer.new(options)
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
    assert_equal([ "codec gzip test message",
                   "codec none test message",
                   "codec snappy test message",
                   "test message" ],
                 found.map(&:to_s).uniq.sort)
  end

  def produce_to_different_topics
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg('apple', nil,      'apple message')
    producer.send_msg('cabin', nil,      'cabin message')
    producer.send_msg('carburetor', nil, 'carburetor message')
  end

  def test_topic_whitelist
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'topics',
      :include_topics => 'ca.*',
    }
    produce_to_different_topics
    consumer = Kafka::Consumer.new(options)
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
    assert(found.include?("cabin message"))
    assert(found.include?("carburetor message"))
    assert(!found.include?("apple message"))
  end

  def test_topic_blacklist
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'topics',
      :exclude_topics => 'ca.*',
    }
    produce_to_different_topics
    consumer = Kafka::Consumer.new(options)
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
    assert(!found.include?("cabin message"))
    assert(!found.include?("carburetor message"))
    assert(found.include?("apple message"))
  end

end
