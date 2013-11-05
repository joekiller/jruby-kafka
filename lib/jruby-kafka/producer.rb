# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/error"

java_import 'org.I0Itec.zkclient.exception.ZkException'

class Kafka::Producer
  @topic
  @zk_connect

  # Create a Kafka Producer
  #
  # options:
  # :zk_connect => "localhost:2181" - REQUIRED: The connection string for the
  #   zookeeper connection in the form host:port. Multiple URLS can be given to allow fail-over.
  # :zk_connect_timeout => "6000" - (optional) The max time that the client waits while establishing a connection to zookeeper.
  # :topic_id => "topic" - REQUIRED: The topic id to consume on.
  # :broker_list => "localhost:9092" - REQUIRED: a seed list of kafka brokers
  def initialize(options={})
    validate_required_arguments(options)

    @zk_connect = options[:zk_connect]
    @topic = options[:topic_id]
    @brokers = options[:broker_list]
    @zk_session_timeout = '6000'
    @zk_connect_timeout = '6000'
    @zk_sync_time = '2000'
    @auto_offset_reset = 'largest'
    @auto_commit_interval = '1000'
    @running = false
    @rebalance_max_retries = '4'
    @rebalance_backoff_ms = '2000'
    @socket_timeout_ms = "#{30 * 1000}"
    @socket_receive_buffer_bytes = "#{64 * 1024}"
    @auto_commit_enable = "#{true}"
    @queued_max_message_chunks = '10'
    @refresh_leader_backoff_ms = '200'
    @consumer_timeout_ms = '-1'

    if options[:zk_connect_timeout]
      @zk_connect_timeout = "#{options[:zk_connect_timeout]}"
    end
    if options[:zk_session_timeout]
      @zk_session_timeout = "#{options[:zk_session_timeout]}"
    end
    if options[:zk_sync_time]
      @zk_sync_time = "#{options[:zk_sync_time]}"
    end
    if options[:auto_commit_interval]
      @auto_commit_interval = "#{options[:auto_commit_interval]}"
    end

    if options[:rebalance_max_retries]
      @rebalance_max_retries = "#{options[:rebalance_max_retries]}"
    end

    if options[:rebalance_backoff_ms]
      @rebalance_backoff_ms = "#{options[:rebalance_backoff_ms]}"
    end

    if options[:socket_timeout_ms]
      @socket_timeout_ms = "#{options[:socket_timeout_ms]}"
    end

    if options[:socket_receive_buffer_bytes]
      @socket_receive_buffer_bytes = "#{options[:socket_receive_buffer_bytes]}"
    end

    if options[:auto_commit_enable]
      @auto_commit_enable = "#{options[:auto_commit_enable]}"
    end

    if options[:refresh_leader_backoff_ms]
      @refresh_leader_backoff_ms = "#{options[:refresh_leader_backoff_ms]}"
    end

    if options[:consumer_timeout_ms]
      @consumer_timeout_ms = "#{options[:consumer_timeout_ms]}"
    end

  end

  private
  def validate_required_arguments(options={})
    [:zk_connect, :broker_list, :topic_id].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
  end

  public
  def shutdown()
    @running = false
  end

  public
  def connect()
    @producer = Java::kafka::producer::Producer.new(createProducerConfig)
  end

  public
  def sendMsg(key,msg)
    m = Java::kafka::producer::KeyedMessage.new(topic=@topic,key=key, message=msg)
    #the send message for a producer is scala varargs, which doesn't seem to play nice w/ jruby
    #  this is the best I could come up with
    ms = Java::scala::collection::immutable::Vector.new(0,0,0)
    ms = ms.append_front(m)
    @producer.send(ms)
  end

  public
  def running?
    @running
  end

  def createProducerConfig()
    # TODO lots more options avaiable here: http://kafka.apache.org/documentation.html#producerconfigs
    properties = java.util.Properties.new()
    properties.put("zookeeper.connect", @zk_connect)
    properties.put("zookeeper.connection.timeout.ms", @zk_connect_timeout)
    properties.put("zookeeper.session.timeout.ms", @zk_session_timeout)
    properties.put("zookeeper.sync.time.ms", @zk_sync_time)
    properties.put("serializer.class", "kafka.serializer.StringEncoder")
    properties.put("request.required.acks", "1")
    properties.put("metadata.broker.list", @brokers)
    return Java::kafka::producer::ProducerConfig.new(properties)
  end
end
