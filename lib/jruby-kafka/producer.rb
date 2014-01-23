# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/error"

java_import 'kafka.common.FailedToSendMessageException'

class Kafka::Producer
  @topic

  # Create a Kafka Producer
  #
  # options:
  # :topic_id => "topic" - REQUIRED: The topic id to consume on.
  # :broker_list => "localhost:9092" - REQUIRED: a seed list of kafka brokers
  def initialize(options={})
    validate_required_arguments(options)

    @brokers = options[:broker_list]
    @serializer_class = 'kafka.serializer.StringEncoder'
    @partitioner_class = nil
    @request_required_acks = '0'
    @compression_codec = "#{Java::kafka::message::NoCompressionCodec.name}"
    @compressed_topics = ''

    if options[:partitioner_class]
      @partitioner_class = "#{options[:partitioner_class]}"
    end

    if options[:request_required_acks]
      @request_required_acks = "#{options[:request_required_acks]}"
    end

    if options[:compression_codec]
      required_codecs = ["#{Java::kafka::message::NoCompressionCodec.name}",
                         "#{Java::kafka::message::GZIPCompressionCodec.name}",
                         "#{Java::kafka::message::SnappyCompressionCodec.name}"]
      if not required_codecs.include? options[:compression_codec]
        raise(ArgumentError, "#{options[:compression_codec]} is not one of required codecs: #{required_codecs}")
      end
      @compression_codec = options[:compression_codec]
    end

    if options[:compressed_topics]
      if @compression_codec != 'none'
        @compressed_topics = options[:compressed_topics]
      end
    end
  end

  private
  def validate_required_arguments(options={})
    [:broker_list].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
  end

  public
  def connect()
    @producer = Java::kafka::producer::Producer.new(createProducerConfig)
  end

  public
  def sendMsg(topic, key, msg)
    m = Java::kafka::producer::KeyedMessage.new(topic=topic, key=key, message=msg)
    #the send message for a producer is scala varargs, which doesn't seem to play nice w/ jruby
    #  this is the best I could come up with
    ms = Java::scala::collection::immutable::Vector.new(0,0,0)
    ms = ms.append_front(m)
    begin
      @producer.send(ms)
    rescue FailedToSendMessageException => e
      raise KafkaError.new(e), "Got FailedToSendMessageException: #{e}"
    end
  end

  def createProducerConfig()
    # TODO lots more options avaiable here: http://kafka.apache.org/documentation.html#producerconfigs
    properties = java.util.Properties.new()
    properties.put("metadata.broker.list", @brokers)
    properties.put("request.required.acks", @request_required_acks)
    if not @partitioner_class.nil?
      properties.put("partitioner.class", @partitioner_class)
    end
    properties.put("serializer.class", @serializer_class)
    properties.put("compression.codec", @compression_codec)
    properties.put("compressed.topics", @compressed_topics)
    return Java::kafka::producer::ProducerConfig.new(properties)
  end
end
