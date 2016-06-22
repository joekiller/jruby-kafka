require 'jruby-kafka/namespace'
require 'jruby-kafka/utility'

# noinspection JRubyStringImportInspection
class Kafka::KafkaProducer <  Java::org.apache.kafka.clients.producer.KafkaProducer
  java_import 'org.apache.kafka.clients.producer.ProducerRecord'
  java_import 'org.apache.kafka.clients.producer.Callback'

  class RubyCallback
    include Callback

    def initialize(cb)
      @cb = cb
    end
    
    def onCompletion(metadata, exception)
      @cb.call(metadata, exception)
    end
  end

  attr_reader :properties

  # Create a Kafka producer.
  #
  # @param [Hash] config the producer configuration.
  #
  # @option config [String]  :bootstrap_servers A list of host/port pairs to use for establishing the initial connection to the Kafka cluster. Required.
  # @option config [String]  :key_serializer Serializer class for key that implements the Deserializer interface. Required.
  # @option config [String]  :value_serializer Serializer class for value that implements the Deserializer interface. Required.
  #
  # For other configuration properties and their default values see 
  # http://kafka.apache.org/documentation.html#producerconfigs and
  # http://kafka.apache.org/0100/javadoc/index.html?org/apache/kafka/clients/consumer/KafkaConsumer.html.
  #
  def initialize(opts = {})
    @properties = opts.clone
    super Kafka::Utility.java_properties @properties
  end

  java_alias :send_method   , :send, [ProducerRecord]
  java_alias :send_cb_method, :send, [ProducerRecord, Callback.java_class]

  # Send a message to the cluster.
  #
  # @param [String]      topic      The topic to send the message to.
  # @param [Integer,nil] partition  The topic partition to send the message to, or nil to allow
  #                                 the configured partitioner class to select the partition.
  # @param [String,nil]  key        The message key, if there is one.  Otherwise, nil.
  # @param [String]      value      The message value.
  # @param [Integer,nil] timestamp  The message timestamp in milliseconds. If nil, the 
  #                                 producer will assign it the current time.
  #   
  # @raise [FailedToSendMessageException] if it can't send the message
  def send_msg(topic, partition, key, value, timestamp=nil, &block)
    record = ProducerRecord.new(topic, partition, timestamp, key, value)

    if block
      send_cb_method record, RubyCallback.new(block)
    else
      send_method record
    end
  end
end
