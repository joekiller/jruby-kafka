require 'java'
require 'jruby-kafka/namespace'
require 'jruby-kafka/utility'

class Kafka::Consumer
  java_import 'org.I0Itec.zkclient.exception.ZkException'
  java_import 'kafka.consumer.ConsumerConfig'
  java_import 'kafka.consumer.Consumer'
  java_import 'kafka.consumer.Whitelist'
  java_import 'kafka.consumer.Blacklist'
  java_import 'kafka.utils.ZkUtils'
  # Create a Kafka high-level consumer.
  #
  # @param [Hash] config the consumer configuration.
  #
  # @option config [String]  :zookeeper_connect The connection string for the zookeeper connection in
  #   the form "host:port[path][,host:port[path]*". Required.
  # @option config [String]  :group_id The consumer group this instance is a member of. Required.
  # @option config [String]  :topic The topic to consume from.
  # @option config [String]  :include_topics The inclusive (white) regular expression filter matching
  #   topics to consume from.
  # @option config [String]  :exclude_topics The exclusive (black) regular expression filter matching
  #   topics not to consume from.
  # @option config [Integer] :num_streams (1) The number of message streams to create.
  # @option config [String]  :key_decoder ('kafka.serializer.DefaultDecoder') Java class name for
  #   message key decoder.
  # @option config [String]  :msg_decoder ('kafka.serializer.DefaultDecoder') Java class name for
  #   message value decoder.
  # @option config [String]  :reset_beginning Delete existing consumer group offsets. Must be "from-beginning" to have
  #   any effect. :auto_offset_reset must be also be "smallest".
  #
  # One and only one of :topic, :include_topics, or :exclude_topics must be provided.
  #
  # For other configuration properties and their default values see 
  # https://kafka.apache.org/08/configuration.html#consumerconfigs and
  # https://github.com/apache/kafka/blob/0.8.2.2/core/src/main/scala/kafka/consumer/ConsumerConfig.scala#L90-L182.
  #
  def initialize(config={})
    validate_arguments config

    @properties      =  config.clone
    @topic           =  @properties.delete :topic
    @include_topics  =  @properties.delete :include_topics
    @exclude_topics  =  @properties.delete :exclude_topics
    @num_streams     = (@properties.delete(:num_streams) || 1).to_java Java::int
    @key_decoder     =  @properties.delete(:key_decoder) || 'kafka.serializer.DefaultDecoder'
    @msg_decoder     =  @properties.delete(:msg_decoder) || 'kafka.serializer.DefaultDecoder'
    @reset_beginning =  @properties.delete :reset_beginning

    @consumer = Consumer.createJavaConsumerConnector ConsumerConfig.new Kafka::Utility.java_properties @properties
  end

  # Start fetching messages.
  #
  # @return [Array<Java::KafkaConsumer::KafkaStream>] list of stream, as specified by the 
  #   :num_stream configuration parameter. A stream is essentially a queue of incomnig messages
  #   from Kafka topic partitions.
  #
  # @see http://apache.osuosl.org/kafka/0.8.2.2/scaladoc/index.html#kafka.consumer.KafkaStream
  # 
  # @note KafkaStreams instances are not thread-safe.
  def message_streams
    begin
      if @reset_beginning == 'from-beginning'
        ZkUtils.maybeDeletePath(@properties[:zookeeper_connect], "/consumers/#{@properties[:group_id]}")
      end
    rescue ZkException => e
      raise KafkaError.new(e), "Got ZkException: #{e}"
    end
    key_decoder_i = Java::JavaClass.for_name(@key_decoder).
      constructor('kafka.utils.VerifiableProperties').new_instance nil
    msg_decoder_i = Java::JavaClass.for_name(@msg_decoder).
      constructor('kafka.utils.VerifiableProperties').new_instance nil

    if @topic
      topic_count_map = java.util.HashMap.new @topic => @num_streams
      @consumer.
        createMessageStreams(topic_count_map, key_decoder_i, msg_decoder_i)[@topic].
        to_a

    else
      filter =  @include_topics ? 
        Whitelist.new(@include_topics) :
        Blacklist.new(@exclude_topics)

      @consumer.
        createMessageStreamsByFilter(filter, @num_streams, key_decoder_i, msg_decoder_i).
        to_a

    end
  end

  # Commit the offsets of all topic partitions connected by this consumer.
  #
  # Useful for when the :auto_commit_enable configuration parameter is false.
  #
  # @return void
  def commitOffsets
    @consumer.commitOffsets
  end

  # Shutdown the consumer.
  #
  # @return void
  def shutdown
    @consumer.shutdown if @consumer
    nil
  end
  
  private

  def validate_arguments(options)
    [:zookeeper_connect, :group_id].each do |opt|
      raise ArgumentError, "Parameter :#{opt} is required." unless options[opt]
    end

    unless [ options[:topic], options[:include_topics], options[:exclude_topics] ].one?
      raise ArgumentError, "Exactly one of :topic, :include_topics, :exclude_topics is required."
    end

    if options[:reset_beginning]
      unless options[:auto_offset_reset] && options[:auto_offset_reset] == 'smallest'
        raise KafkaError.new('reset_beginning => from-beginning must be used with auto_offset_reset => smallest')
      end
    end
  end
end

