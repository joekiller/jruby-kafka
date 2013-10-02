# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/consumer"

java_import 'java.util.concurrent.ExecutorService'
java_import 'java.util.concurrent.Executors'

class Kafka::Group
  @consumer
  @executor
  @topic
  @auto_offset_reset
  @zk_connect
  @group_id

  # Create a Kafka client group
  #
  # options:
  # :zk_connect_opt => "localhost:2181" - REQUIRED: The connection string for the
  #   zookeeper connection in the form host:port. Multiple URLS can be given to allow fail-over.
  # :group_id_opt => "group" - REQUIRED: The group id to consume on.
  # :topic_id_opt => "topic" - REQUIRED: The topic id to consume on.
  # :message_queue => SizedQueue - REQUIRED: The message queue which consumer threads will populate.
  # :reset_beginning_opt => "from-beginning" - (optional) If the consumer does not already have an established offset
  #   to consume from, start with the earliest message present in the log rather than the latest message.
  def initialize(options={})
    validate_required_arguments(options)

    @zk_connect = options[:zk_connect_opt]
    @group_id = options[:group_id_opt]
    @topic = options[:topic_id_opt]
    @message_queue = options[:message_queue]


    if options[:reset_beginning_opt]
      if options[:reset_beginning_opt] == 'from-beginning'
        @auto_offset_reset = 'smallest'
      else
        @auto_offset_reset = 'largest'
      end
    else
      @auto_offset_reset = 'largest'
    end

    if @auto_offset_reset == 'smallest'
      Java::kafka::utils::ZkUtils.maybeDeletePath(@zk_connect, "/consumers/#{@group_id}")
    end

    @consumer = Java::kafka::consumer::Consumer.createJavaConsumerConnector(createConsumerConfig())
  end

  private
  def validate_required_arguments(options={})
    [:zk_connect_opt, :group_id_opt, :topic_id_opt, :message_queue].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
    raise(ArgumentError, ":message_queue must be type SizedQueue.") unless options[:message_queue].is_a?(SizedQueue)
  end

  public
  def shutdown()
    if @consumer
      @consumer.shutdown()
    end
    if @executor
      @executor.shutdown()
    end
  end

  public
  def run(a_numThreads)
    topicCountMap = java.util.HashMap.new()
    thread_value = a_numThreads.to_java Java::int
    topicCountMap.put(@topic, thread_value)
    consumerMap = @consumer.createMessageStreams(topicCountMap)
    streams = Array.new(consumerMap[@topic])

    @executor = Executors.newFixedThreadPool(a_numThreads)

    threadNumber = 0
    for stream in streams
      @executor.submit(Kafka::Consumer.new(stream, threadNumber, @message_queue))
      threadNumber += 1
    end
  end

  private
  def createConsumerConfig()
    properties = java.util.Properties.new()
    properties.put("zookeeper.connect", @zk_connect)
    properties.put("group.id", @group_id)
    properties.put("zookeeper.session.timeout.ms", "400")
    properties.put("zookeeper.sync.time.ms", "200")
    properties.put("auto.commit.interval.ms", "1000")
    properties.put("auto.offset.reset", @auto_offset_reset)
    return Java::kafka::consumer::ConsumerConfig.new(properties)
  end
end
