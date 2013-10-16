# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/consumer"
require "jruby-kafka/error"

java_import 'java.util.concurrent.ExecutorService'
java_import 'java.util.concurrent.Executors'
java_import 'org.I0Itec.zkclient.exception.ZkException'

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
  # :zk_connect => "localhost:2181" - REQUIRED: The connection string for the
  #   zookeeper connection in the form host:port. Multiple URLS can be given to allow fail-over.
  # :zk_connect_timeout => "6000" - (optional) The max time that the client waits while establishing a connection to zookeeper.
  # :group_id => "group" - REQUIRED: The group id to consume on.
  # :topic_id => "topic" - REQUIRED: The topic id to consume on.
  # :reset_beginning => "from-beginning" - (optional) If the consumer does not already have an established offset
  #   to consume from, start with the earliest message present in the log rather than the latest message.
  #
  def initialize(options={})
    validate_required_arguments(options)

    @zk_connect = options[:zk_connect]
    @group_id = options[:group_id]
    @topic = options[:topic_id]
    @zk_session_timeout = '6000'
    @zk_connect_timeout = '6000'
    @zk_sync_time = '2000'
    @auto_offset_reset = 'largest'
    @auto_commit_interval = '1000'

    if options[:zk_connect_timeout]
      @zk_connect_timeout = options[:zk_connect_timeout]
    end
    if options[:zk_session_timeout]
      @zk_session_timeout = options[:zk_session_timeout]
    end
    if options[:zk_sync_time]
      @zk_sync_time = options[:zk_sync_time]
    end
    if options[:auto_commit_interval]
      @auto_commit_interval = options[:auto_commit_interval]
    end


    if options[:reset_beginning]
      if options[:reset_beginning] == 'from-beginning'
        @auto_offset_reset = 'smallest'
      else
        @auto_offset_reset = 'largest'
      end
    end

    begin
      if @auto_offset_reset == 'smallest'
        Java::kafka::utils::ZkUtils.maybeDeletePath(@zk_connect, "/consumers/#{@group_id}")
      end

      @consumer = Java::kafka::consumer::Consumer.createJavaConsumerConnector(createConsumerConfig())
    rescue ZkException => e
      raise KafkaError.new(e), "Got ZkException: #{e}"
    end
  end

  private
  def validate_required_arguments(options={})
    [:zk_connect, :group_id, :topic_id].each do |opt|
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
  def run(a_numThreads, a_queue)
    topicCountMap = java.util.HashMap.new()
    thread_value = a_numThreads.to_java Java::int
    topicCountMap.put(@topic, thread_value)
    consumerMap = @consumer.createMessageStreams(topicCountMap)
    streams = Array.new(consumerMap[@topic])

    @executor = Executors.newFixedThreadPool(a_numThreads)

    threadNumber = 0
    for stream in streams
      @executor.submit(Kafka::Consumer.new(stream, threadNumber, a_queue))
      threadNumber += 1
    end
  end

  private
  def createConsumerConfig()
    properties = java.util.Properties.new()
    properties.put("zookeeper.connect", @zk_connect)
    properties.put("group.id", @group_id)
    properties.put("zookeeper.connection.timeout.ms", @zk_connect_timeout)
    properties.put("zookeeper.session.timeout.ms", @zk_session_timeout)
    properties.put("zookeeper.sync.time.ms", @zk_sync_time)
    properties.put("auto.commit.interval.ms", @auto_commit_interval)
    properties.put("auto.offset.reset", @auto_offset_reset)
    return Java::kafka::consumer::ConsumerConfig.new(properties)
  end
end
