# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/error"

class Kafka::Producer
  java_import 'kafka.producer.ProducerConfig'
  java_import 'kafka.producer.KeyedMessage'
  KafkaProducer = Java::kafka.javaapi.producer.Producer
  java_import 'kafka.message.NoCompressionCodec'
  java_import 'kafka.message.GZIPCompressionCodec'
  java_import 'kafka.message.SnappyCompressionCodec'

  VALIDATIONS = {
    'request.required.acks' => %w[ 0 1 -1 ],
    'required.codecs' => [NoCompressionCodec.name, GZIPCompressionCodec.name, SnappyCompressionCodec.name],
    'producer.type' => %w[ sync async ]
  }

  REQUIRED = %w[
    metadata.broker.list
  ]

  # List of all available options extracted from http://kafka.apache.org/documentation.html#producerconfigs Apr. 27, 2014
  # If new options are added, they should just work. Please add them to the list so that we can get handy warnings.
  KNOWN = %w[
    acks                   max.request.size              receive.buffer.bytes
    batch.num.messages     message.send.max.retries      reconnect.backoff.ms
    batch.size             metadata.broker.list          request.required.acks
    block.on.buffer.full   metadata.fetch.timeout.ms     request.timeout.ms
    bootstrap.servers      metadata.max.age.ms           retries
    buffer.memory          metric.reporters              retry.backoff.ms
    client.id              metrics.num.samples           retry.backoff.ms
    client.id              metrics.sample.window.ms      send.buffer.bytes
    compressed.topics      partitioner.class             send.buffer.bytes
    compression.codec      producer.type                 serializer.class
    compression.type       queue.buffering.max.messages  timeout.ms
    key.serializer.class   queue.buffering.max.ms        topic.metadata.refresh.interval.ms
    linger.ms              queue.enqueue.timeout.ms
  ]

  attr_reader :producer, :send_method, :options

  # Create a Kafka Producer
  #
  # options:
  # metadata_broker_list: ["localhost:9092"] - REQUIRED: a seed list of kafka brokers
  def initialize(opts = {})
    @options = opts.reduce({}) do |opts, (k, v)|
      opts[k.to_s.gsub(/_/, '.')] = v
      opts
    end
    if options['broker.list']
      options['metadata.broker.list'] = options.delete 'broker.list'
    end
    if options['compressed.topics'].to_s == 'none'
      options.delete 'compressed.topics'
    end
    if options['metadata.broker.list'].is_a? Array
      options['metadata.broker.list'] = options['metadata.broker.list'].join(',')
    end
    validate_arguments
    @send_method = proc { throw StandardError.new "Producer is not connected" }
  end

  def connect()
    @producer = KafkaProducer.new(createProducerConfig)
    @send_method = producer.java_method :send, [KeyedMessage]
  end

  # throws FailedToSendMessageException or if not connected, StandardError.
  def sendMsg(topic, key, msg)
    if key.nil? send_method.call(KeyedMessage.new(topic, msg)) : send_method.call(KeyedMessage.new(topic, key, msg))
  end

  private

  def validate_arguments
    errors = []
    missing = REQUIRED.reject { |opt| options[opt] }
    errors = ["Required settings: #{ missing.join(', ')}"] if missing.any?
    invalid = VALIDATIONS.reject { |opt, valid| options[opt].nil? or valid.include? options[opt].to_s }
    errors += invalid.map { |opt, valid| "#{ opt } should be one of: [#{ valid.join(', ')}]" }
    fail StandardError.new "Invalid configuration arguments: #{ errors.join('; ') }" if errors.any?
    options.keys.each do |opt|
      STDERR.puts "WARNING: Unknown configuration key: #{opt}" unless KNOWN.include? opt
    end
  end

  def createProducerConfig()
    properties = java.util.Properties.new()
    options.each { |opt, value| properties.put opt, value.to_s }
    return ProducerConfig.new(properties)
  end
end
