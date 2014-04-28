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

  attr_reader :producer, :send_method

  # Create a Kafka Producer
  #
  # options:
  # :broker_list => "localhost:9092" - REQUIRED: a seed list of kafka brokers
  def initialize(options={})
    validate_required_arguments(options)
    @send_method = proc { throw StandardError.new "Producer is not connected" }

    @metadata_broker_list = options[:broker_list]
    @serializer_class = nil
    @partitioner_class = nil
    @request_required_acks = nil
    @compression_codec = nil
    @compressed_topics = nil
    @request_timeout_ms = nil
    @producer_type = nil
    @key_serializer_class = nil
    @message_send_max_retries = nil
    @retry_backoff_ms = nil
    @topic_metadata_refresh_interval_ms = nil
    @queue_buffering_max_ms = nil
    @queue_buffering_max_messages = nil
    @queue_enqueue_timeout_ms = nil
    @batch_num_messages = nil
    @send_buffer_bytes = nil
    @client_id = nil

    if options[:partitioner_class]
      @partitioner_class = "#{options[:partitioner_class]}"
    end

    if options[:request_required_acks]
      valid_acks = %w{ 0 1 -1 }
      if not valid_acks.include? "#{options[:request_required_acks]}"
        raise(ArgumentError, "#{options[:request_required_acks]} is not a valid request_required_acks value: #{valid_acks}")
      end
      @request_required_acks = "#{options[:request_required_acks]}"
    end

    if options[:compression_codec]
      required_codecs = ["#{NoCompressionCodec.name}",
                         "#{GZIPCompressionCodec.name}",
                         "#{SnappyCompressionCodec.name}"]
      if not required_codecs.include? "#{options[:compression_codec]}"
        raise(ArgumentError, "#{options[:compression_codec]} is not one of required codecs: #{required_codecs}")
      end
      @compression_codec = "#{options[:compression_codec]}"
    end

    if options[:compressed_topics]
      if @compression_codec != 'none'
        @compressed_topics = "#{options[:compressed_topics]}"
      end
    end

    if options[:request_timeout_ms]
      @request_timeout_ms = "#{options[:request_timeout_ms]}"
    end

    if options[:producer_type]
      valid_producer_types = %w{ sync async }
      if not valid_producer_types.include? "#{options[:producer_type]}"
        raise(ArgumentError, "#{options[:producer_type]} is not a valid producer type: #{valid_producer_types}")
      end
      @producer_type = "#{options[:producer_type]}"
    end

    if options[:serializer_class]
      @serializer_class = "#{options[:serializer_class]}"
    end

    if options[:key_serializer_class]
      @key_serializer_class = "#{options[:key_serializer_class]}"
    end

    if options[:message_send_max_retries]
      @message_send_max_retries = "#{options[:message_send_max_retries]}"
    end

    if options[:retry_backoff_ms]
      @retry_backoff_ms = "#{options[:retry_backoff_ms]}"
    end

    if options[:topic_metadata_refresh_interval_ms]
      @topic_metadata_refresh_interval_ms = "#{options[:topic_metadata_refresh_interval_ms]}"
    end

    if options[:queue_buffering_max_ms]
      @queue_buffering_max_ms = "#{options[:queue_buffering_max_ms]}"
    end

    if options[:queue_buffering_max_messages]
      @queue_buffering_max_messages = "#{options[:queue_buffering_max_messages]}"
    end

    if options[:queue_enqueue_timeout_ms]
      @queue_enqueue_timeout_ms = "#{options[:queue_enqueue_timeout_ms]}"
    end

    if options[:batch_num_messages]
      @batch_num_messages = "#{options[:batch_num_messages]}"
    end

    if options[:send_buffer_bytes]
      @send_buffer_bytes = "#{options[:send_buffer_bytes]}"
    end

    if options[:client_id]
      @client_id = "#{options[:client_id]}"
    end
  end

  public
  def connect()
    @producer = KafkaProducer.new(createProducerConfig)
    @send_method = producer.java_method :send, [KeyedMessage]
  end

  # throws FailedToSendMessageException or if not connected, StandardError.
  def sendMsg(topic, key, msg)
    send_method.call(KeyedMessage.new(topic, key, msg))
  end

  private
  def validate_required_arguments(options={})
    [:broker_list].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
  end

  def createProducerConfig()
    # TODO lots more options avaiable here: http://kafka.apache.org/documentation.html#producerconfigs
    properties = java.util.Properties.new()
    properties.put("metadata.broker.list", @metadata_broker_list)
    unless @request_required_acks.nil?
      properties.put("request.required.acks", @request_required_acks)
    end
    unless @partitioner_class.nil?
      properties.put("partitioner.class", @partitioner_class)
    end
    unless @key_serializer_class.nil?
      properties.put("key.serializer.class", @key_serializer_class)
    end
    unless @request_timeout_ms.nil?
      properties.put("request.timeout.ms", @request_timeout_ms)
    end
    unless @producer_type.nil?
      properties.put('producer.type', @producer_type)
    end
    unless @serializer_class.nil?
      properties.put("serializer.class", @serializer_class)
    end
    unless @compression_codec.nil?
      properties.put("compression.codec", @compression_codec)
    end
    unless @compressed_topics.nil?
      properties.put("compressed.topics", @compressed_topics)
    end
    unless @message_send_max_retries.nil?
      properties.put("message.send.max.retries", @message_send_max_retries)
    end
    unless @retry_backoff_ms.nil?
      properties.put('retry.backoff.ms', @retry_backoff_ms)
    end
    unless @topic_metadata_refresh_interval_ms.nil?
      properties.put('topic.metadata.refresh.interval.ms', @topic_metadata_refresh_interval_ms)
    end
    unless @queue_buffering_max_ms.nil?
      properties.put('queue.buffering.max.ms', @queue_buffering_max_ms)
    end
    unless @queue_buffering_max_messages.nil?
      properties.put('queue.buffering.max.messages', @queue_buffering_max_messages)
    end
    unless @queue_enqueue_timeout_ms.nil?
      properties.put('queue.enqueue.timeout.ms', @queue_enqueue_timeout_ms)
    end
    unless @batch_num_messages.nil?
      properties.put('batch.num.messages', @batch_num_messages)
    end
    unless @send_buffer_bytes.nil?
      properties.put('send.buffer.bytes', @send_buffer_bytes)
    end
    unless @client_id.nil?
      properties.put('client.id', @client_id)
    end
    return ProducerConfig.new(properties)
  end
end
