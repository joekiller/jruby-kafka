require 'jruby-kafka'

PRODUCER_OPTIONS = {
    :broker_list => '127.0.0.1:9092',
    :serializer_class => 'kafka.serializer.StringEncoder'
}

def produce_to_different_topics(topic_prefix = '')
  producer = Kafka::Producer.new(PRODUCER_OPTIONS)
  producer.connect
  producer.send_msg(topic_prefix + 'apple', nil,      'apple message')
  producer.send_msg(topic_prefix + 'cabin', nil,      'cabin message')
  producer.send_msg(topic_prefix + 'carburetor', nil, 'carburetor message')
end

def send_producer_msg(topic = 'test')
  producer = Kafka::Producer.new(PRODUCER_OPTIONS)
  producer.connect
  producer.send_msg(topic, nil, 'test message')
end

def send_producer_msg_deprecated(topic = 'test')
  producer = Kafka::Producer.new(PRODUCER_OPTIONS)
  producer.connect
  producer.sendMsg(topic, nil, 'test message')
end

def send_producer_msg_compressed(compression_codec='none', topic='test')
  options = PRODUCER_OPTIONS.clone
  options[:compression_codec] = compression_codec
  producer = Kafka::Producer.new(options)
  producer.connect
  producer.send_msg(topic,nil, "codec #{compression_codec} test message")
end

def send_compression_none(topic = 'test')
  send_producer_msg_compressed('none', topic)
end

def send_compression_gzip(topic = 'test')
  send_producer_msg_compressed('gzip', topic)
end

def send_compression_snappy(topic = 'test')
  #snappy test may fail on mac, see https://code.google.com/p/snappy-java/issues/detail?id=39
  send_producer_msg_compressed('snappy', topic)
end

def send_test_messages(topic = 'test')
  send_compression_none topic
  send_compression_gzip topic
  send_compression_snappy topic
  send_producer_msg topic
end