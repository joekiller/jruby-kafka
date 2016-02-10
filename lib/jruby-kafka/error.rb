require 'jruby-kafka/version'

class KafkaError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end
end