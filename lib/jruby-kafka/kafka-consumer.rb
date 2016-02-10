require 'java'
require 'jruby-kafka/version'

class Kafka::KafkaConsumer
  KAFKA_CONSUMER = Java::org.apache.kafka.clients.consumer.KafkaConsumer

  attr_reader :consumer

  def initialize(config={})
    @properties =  config.clone
    @consumer = KAFKA_CONSUMER.new(create_config)
  end
  
  private
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

