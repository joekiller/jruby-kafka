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
  # :zkConnectOpt => "localhost:2181" - REQUIRED: The connection string for the
  #   zookeeper connection in the form host:port. Multiple URLS can be given to allow fail-over.
  # :groupIdOpt => "group" - The group id to consume on.
  # :topicIdOpt => "topic" - The topic id to consume on.
  # :resetBeginningOpt => "from-beginning" - (optional) If the consumer does not already have an established offset
  #   to consume from, start with the earliest message present in the log rather than the latest message.
  def initialize(options={})
    validate_required_arguments(options)

    @zk_connect = options[:zkConnectOpt]
    @group_id = options[:groupIdOpt]
    @topic = options[:topicIdOpt]

    if options[:resetBeginningOpt]
      if options[:resetBeginningOpt] == 'from-beginning'
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
    [:zkConnectOpt, :groupIdOpt, :topicIdOpt].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
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
      @executor.submit(Kafka::Consumer.new(stream, threadNumber))
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
