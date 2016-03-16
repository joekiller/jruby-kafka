require 'java'
require 'jruby-kafka/namespace'
require "concurrent"

class Kafka::KafkaConsumer
  KAFKA_CONSUMER = Java::org.apache.kafka.clients.consumer.KafkaConsumer
  # Create a Kafka high-level consumer.
  #
  # @param [Hash] config the consumer configuration.
  #
  # @option config [String]  :bootstrap_servers A list of host/port pairs to use for establishing the initial connection to the Kafka cluster. The client will make use of all servers irrespective of which servers are specified here for bootstrapping—this list only impacts the initial hosts used to discover the full set of servers. This list should be in the form host1:port1,host2:port2,.... Since these servers are just used for the initial connection to discover the full cluster membership (which may change dynamically), this list need not contain the full set of servers (you may want more than one, though, in case a server is down). Required.
  # @option config [String]  :key_deserializer Deserializer class for key that implements the Deserializer interface. Required.
  # @option config [String]  :value_deserializer Deserializer class for value that implements the Deserializer interface. Required.
  # @option config [Array]   :topics The topic to consume from. Required.
  #
  #
  # For other configuration properties and their default values see 
  # http://kafka.apache.org/documentation.html#newconsumerconfigs and
  # https://kafka.apache.org/090/javadoc/org/apache/kafka/clients/consumer/ConsumerConfig.html.
  #
  def initialize(config={})
    validate_arguments config
    @properties      =  config.clone
    @topics          =  @properties.delete :topics
    @stop_called     =  Concurrent::AtomicBoolean.new(false)
    @consumer        =  KAFKA_CONSUMER.new(create_config)
    @subscribed      =  false
    subscribe
  end

  attr_reader :properties, :topics

  def stop
    @stop_called.make_true
    @consumer.wakeup
  end

  # Subscribe to topics
  def subscribe
    @consumer.subscribe(@topics)
    @subscribed = true
    nil
  end

  # stop? should never be overriden
  def stop?
    @stop_called.value
  end

  # Fetch data for the topics or partitions specified using one of the subscribe/assign APIs.
  def poll(timeout)
    @consumer.poll timeout
  end

  def close
    @consumer.close
  end

  private

  def validate_arguments(options)
    [:bootstrap_servers, :key_deserializer, :value_deserializer].each do |opt|
      raise ArgumentError, "Parameter :#{opt} is required." unless options[opt]
    end
  end

  def create_config
    properties = java.util.Properties.new
    @properties.each do |k,v|
      k = k.to_s.gsub '_', '.'
      v = v.to_s 
      properties.setProperty k, v
    end
    properties
  end
end

