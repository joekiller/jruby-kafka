require 'jruby-kafka/namespace'
require 'jruby-kafka/error'
require 'jruby-kafka/utility'

# noinspection JRubyStringImportInspection
class Kafka::KafkaProducer
  java_import 'org.apache.kafka.clients.producer.ProducerRecord'
  java_import 'org.apache.kafka.clients.producer.Callback'
  KAFKA_PRODUCER = Java::org.apache.kafka.clients.producer.KafkaProducer

  REQUIRED = [
    :bootstrap_servers, :key_serializer
  ]

  class RubyCallback
    include Callback

    def initialize(cb)
      @cb = cb
    end
    
    def onCompletion(metadata, exception)
      @cb.call(metadata, exception)
    end
  end

  attr_reader :producer, :send_method, :send_cb_method, :options

  def initialize(opts = {})
    Kafka::Utility.validate_arguments REQUIRED, opts
    @options = opts
    @send_method = @send_cb_method = proc { throw StandardError.new 'Producer is not connected' }
  end

  def connect
    @producer = KAFKA_PRODUCER.new(Kafka::Utility.java_properties @options)
    @send_method = producer.java_method :send, [ProducerRecord]
    @send_cb_method = producer.java_method :send, [ProducerRecord, Callback.java_class]
  end

  # throws FailedToSendMessageException or if not connected, StandardError.
  def send_msg(topic, partition, key, value, &block)
    if block
      send_cb_method.call(ProducerRecord.new(topic, partition, key, value), RubyCallback.new(block))
    else
      send_method.call(ProducerRecord.new(topic, partition, key, value))
    end
  end

  def close
    @producer.close
  end
end
