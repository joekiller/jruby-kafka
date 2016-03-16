# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example
require 'jruby-kafka/namespace'
require 'jruby-kafka/error'
require 'jruby-kafka/utility'

# noinspection JRubyStringImportInspection
class Kafka::Producer
  extend Gem::Deprecate
  java_import 'kafka.producer.ProducerConfig'
  java_import 'kafka.producer.KeyedMessage'
  KAFKA_PRODUCER = Java::kafka.javaapi.producer.Producer

  REQUIRED = [
    :metadata_broker_list
  ]

  attr_reader :producer, :send_method, :options

  # Create a Kafka Producer
  #
  # options:
  # metadata_broker_list: ["localhost:9092"] - REQUIRED: a seed list of kafka brokers
  def initialize(opts = {})
    @options = opts
    if options[:broker_list]
      options[:metadata_broker_list] = options.delete :broker_list
    end
    if options[:metadata_broker_list].is_a? Array
      options[:metadata_broker_list] = options[:metadata_broker_list].join(',')
    end
    if options[:compressed_topics].is_a? Array
      options[:compressed_topics] = options[:compressed_topics].join(',')
    end
    Kafka::Utility.validate_arguments REQUIRED, options
    @send_method = proc { throw StandardError.new 'Producer is not connected' }
  end

  def connect
    @producer = KAFKA_PRODUCER.new(ProducerConfig.new Kafka::Utility.java_properties @options)
    @send_method = producer.java_method :send, [KeyedMessage]
  end

  # throws FailedToSendMessageException or if not connected, StandardError.
  def send_msg(topic, key, msg)
    send_method.call(KeyedMessage.new(topic, key, msg))
  end

  def sendMsg(topic, key, msg)
    send_msg(topic, key, msg)
  end
  deprecate :sendMsg, :send_msg, 2015, 01

  def close
    @producer.close
  end
end
