# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

require 'java'

require 'jruby-kafka/namespace'
require 'jruby-kafka/consumer'
require 'jruby-kafka/error'

# noinspection JRubyStringImportInspection
class Kafka::Group
  java_import 'java.util.concurrent.ExecutorService'
  java_import 'java.util.concurrent.Executors'
  java_import 'org.I0Itec.zkclient.exception.ZkException'

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
  # :consumer_restart_on_error => "true" - (optional) Controls if consumer threads are to restart on caught exceptions.
  #   exceptions are logged.
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
    @running = false
    @rebalance_max_retries = '4'
    @rebalance_backoff_ms = '2000'
    @socket_timeout_ms = "#{30 * 1000}"
    @socket_receive_buffer_bytes = "#{64 * 1024}"
    @fetch_message_max_bytes = "#{1024 * 1024}"
    @auto_commit_enable = "#{true}"
    @queued_max_message_chunks = '10'
    @fetch_min_bytes = '1'
    @fetch_wait_max_ms = '100'
    @refresh_leader_backoff_ms = '200'
    @consumer_timeout_ms = '-1'
    @consumer_restart_on_error = "#{false}"
    @consumer_restart_sleep_ms = '0'
    @consumer_id = nil

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

    if options[:fetch_message_max_bytes]
      @fetch_message_max_bytes = "#{options[:fetch_message_max_bytes]}"
    end

    if options[:auto_commit_enable]
      @auto_commit_enable = "#{options[:auto_commit_enable]}"
    end

    if options[:queued_max_message_chunks]
      @queued_max_message_chunks = "#{options[:queued_max_message_chunks]}"
    end

    if options[:fetch_min_bytes]
      @fetch_min_bytes = "#{options[:fetch_min_bytes]}"
    end

    if options[:fetch_wait_max_ms]
      @fetch_wait_max_ms = "#{options[:fetch_wait_max_ms]}"
    end

    if options[:refresh_leader_backoff_ms]
      @refresh_leader_backoff_ms = "#{options[:refresh_leader_backoff_ms]}"
    end

    if options[:consumer_timeout_ms]
      @consumer_timeout_ms = "#{options[:consumer_timeout_ms]}"
    end

    if options[:consumer_restart_on_error]
      @consumer_restart_on_error = "#{options[:consumer_restart_on_error]}"
    end

    if options[:consumer_restart_sleep_ms]
      @consumer_restart_sleep_ms = "#{options[:consumer_restart_sleep_ms]}"
    end


    if options[:reset_beginning]
      if options[:reset_beginning] == 'from-beginning'
        @auto_offset_reset = 'smallest'
      else
        @auto_offset_reset = 'largest'
      end
    end

    if options[:consumer_id]
      @consumer_id = options[:consumer_id]
    end
  end

  public

  def shutdown
    if @consumer
      @consumer.shutdown
    end
    if @executor
      @executor.shutdown
    end
    @running = false
  end

  def run(a_num_threads, a_queue)
    begin
      if @auto_offset_reset == 'smallest'
        Java::kafka::utils::ZkUtils.maybeDeletePath(@zk_connect, "/consumers/#{@group_id}")
      end

      @consumer = Java::kafka::consumer::Consumer.createJavaConsumerConnector(create_consumer_config)
    rescue ZkException => e
      raise KafkaError.new(e), "Got ZkException: #{e}"
    end

    thread_value = a_num_threads.to_java Java::int
    topic_filter = Java::kafka::consumer::Whitelist.new(@topic)
    streams = @consumer.createMessageStreamsByFilter(topic_filter, thread_value)

    @executor = Executors.newFixedThreadPool(a_num_threads)
    @executor_submit = @executor.java_method(:submit, [Java::JavaLang::Runnable.java_class])

    thread_number = 0
    streams.each do |stream|
      @executor_submit.call(Kafka::Consumer.new(stream, thread_number, a_queue, @consumer_restart_on_error, @consumer_restart_sleep_ms))
      thread_number += 1
    end
    @running = true
  end

  def running?
    @running
  end

  private

  def validate_required_arguments(options={})
    [:zk_connect, :group_id, :topic_id].each do |opt|
      raise(ArgumentError, "#{opt} is required.") unless options[opt]
    end
  end

  def create_consumer_config
    properties = java.util.Properties.new
    properties.put('zookeeper.connect', @zk_connect)
    properties.put('group.id', @group_id)
    properties.put('zookeeper.connection.timeout.ms', @zk_connect_timeout)
    properties.put('zookeeper.session.timeout.ms', @zk_session_timeout)
    properties.put('zookeeper.sync.time.ms', @zk_sync_time)
    properties.put('auto.commit.interval.ms', @auto_commit_interval)
    properties.put('auto.offset.reset', @auto_offset_reset)
    properties.put('rebalance.max.retries', @rebalance_max_retries)
    properties.put('rebalance.backoff.ms', @rebalance_backoff_ms)
    properties.put('socket.timeout.ms', @socket_timeout_ms)
    properties.put('socket.receive.buffer.bytes', @socket_receive_buffer_bytes)
    properties.put('fetch.message.max.bytes', @fetch_message_max_bytes)
    properties.put('auto.commit.enable', @auto_commit_enable)
    properties.put('queued.max.message.chunks', @queued_max_message_chunks)
    properties.put('fetch.min.bytes', @fetch_min_bytes)
    properties.put('fetch.wait.max.ms', @fetch_wait_max_ms)
    properties.put('refresh.leader.backoff.ms', @refresh_leader_backoff_ms)
    properties.put('consumer.timeout.ms', @consumer_timeout_ms)
    unless @consumer_id.nil?
      properties.put('consumer.id', @consumer_id)
    end
    Java::kafka::consumer::ConsumerConfig.new(properties)
  end
end
