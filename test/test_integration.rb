require 'test/unit'
require 'jruby-kafka'
require 'util'

class TestKafka < Test::Unit::TestCase

  def send_msg(topic = 'test')
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg(topic, nil, 'test message')
  end

  def send_msg_deprecated(topic = 'test')
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.sendMsg(topic, nil, 'test message')
  end

  def producer_compression_send(compression_codec='none', topic='test')
    options = PRODUCER_OPTIONS.clone
    options[:compression_codec] = compression_codec
    producer = Kafka::Producer.new(options)
    producer.connect
    producer.send_msg(topic,nil, "codec #{compression_codec} test message")
  end

  def send_compression_none(topic = 'test')
    producer_compression_send('none', topic)
  end

  def send_compression_gzip(topic = 'test')
    producer_compression_send('gzip', topic)
  end

  def send_compression_snappy(topic = 'test')
    #snappy test may fail on mac, see https://code.google.com/p/snappy-java/issues/detail?id=39
    producer_compression_send('snappy', topic)
  end

  def send_test_messages(topic = 'test')
    send_compression_none topic
    send_compression_gzip topic
    send_compression_snappy topic
    send_msg topic
  end

  def test_01_run
    topic = 'test_run'
    send_test_messages topic
    queue = SizedQueue.new(20)
    consumer = Kafka::Consumer.new(consumer_options({:topic => topic }))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test stream, queue}
    end
    begin
      timeout(30) do
        until queue.length > 3 do
          sleep 1
          next
        end
      end
    end
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

  def test_02_from_beginning
    topic = 'test_run'
    queue = SizedQueue.new(20)
    options = {
      :topic => topic,
      :reset_beginning => 'from-beginning'
    }
    consumer = Kafka::Consumer.new(consumer_options(options))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test stream, queue}
    end
    begin
      timeout(30) do
        until queue.length > 3 do
          sleep 1
          next
        end
      end
    end
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

  def produce_to_different_topics(topic_prefix = '')
    producer = Kafka::Producer.new(PRODUCER_OPTIONS)
    producer.connect
    producer.send_msg(topic_prefix + 'apple', nil,      'apple message')
    producer.send_msg(topic_prefix + 'cabin', nil,      'cabin message')
    producer.send_msg(topic_prefix + 'carburetor', nil, 'carburetor message')
  end

  def test_03_topic_whitelist
    topic_prefix = 'whitelist'
    produce_to_different_topics topic_prefix
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'topics',
      :include_topics => topic_prefix + 'ca.*',
    }
    consumer = Kafka::Consumer.new(bw_consumer_options(options))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test stream, queue}
    end
    begin
      timeout(30) do
        until queue.length > 1 do
          sleep 1
          next
        end
      end
    end
    consumer.shutdown
    found = []
    until queue.empty?
      found << queue.pop
    end
    assert(found.include?("cabin message"))
    assert(found.include?("carburetor message"))
    assert(!found.include?("apple message"))
  end

  def test_04_topic_blacklist
    topic_prefix = 'blacklist'
    produce_to_different_topics topic_prefix
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'topics',
      :exclude_topics => topic_prefix + 'ca.*',
    }
    consumer = Kafka::Consumer.new(bw_consumer_options(options))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test stream, queue}
    end
    begin
      timeout(30) do
        until queue.length > 0 do
          sleep 1
          next
        end
      end
    end
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
