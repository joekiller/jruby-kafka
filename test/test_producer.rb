require 'test/unit'
require 'jruby-kafka'
require 'util/producer'
require 'util/consumer'

class TestKafka < Test::Unit::TestCase
  def test_01_run
    topic = 'test_run'
    send_test_messages topic
    queue = SizedQueue.new(20)
    consumer = Kafka::Consumer.new(consumer_options({:topic => topic }))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test_blk stream, queue}
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
      Thread.new { consumer_test_blk stream, queue}
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

  def test_03_topic_whitelist
    topic_prefix = 'whitelist'
    produce_to_different_topics topic_prefix
    queue = SizedQueue.new(20)
    options = {
      :zookeeper_connect => '127.0.0.1:2181',
      :group_id => 'topics',
      :include_topics => topic_prefix + 'ca.*',
    }
    consumer = Kafka::Consumer.new(filter_consumer_options(options))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test_blk stream, queue}
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
    consumer = Kafka::Consumer.new(filter_consumer_options(options))
    streams = consumer.message_streams
    streams.each_with_index do |stream|
      Thread.new { consumer_test_blk stream, queue}
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
