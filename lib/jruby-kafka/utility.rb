require 'java'
require 'jruby-kafka/namespace'

class Kafka::Utility
  def self.java_properties(properties)
    java_properties = java.util.Properties.new
    properties.each do |k,v|
      k = k.to_s.gsub '_', '.'
      v = v.to_s
      java_properties.setProperty k, v
    end
    java_properties
  end

  def self.validate_arguments(required_options, options)
    required_options.each do |opt|
      raise ArgumentError, "Parameter :#{opt} is required." unless options[opt]
    end
  end
end
