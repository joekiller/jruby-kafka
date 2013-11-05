require "java"
require "jruby-kafka/namespace"

java_import 'kafka.consumer.ConsumerIterator'
java_import 'kafka.consumer.KafkaStream'
java_import 'kafka.common.ConsumerRebalanceFailedException'
java_import 'kafka.consumer.ConsumerTimeoutException'

class Kafka::Consumer
  include Java::JavaLang::Runnable
  java_signature 'void run()'

  @m_stream
  @m_threadNumber
  @m_queue

    def initialize(a_stream, a_threadNumber, a_queue, a_bool_restart_on_exception, a_sleep_ms)
      @m_threadNumber = a_threadNumber
      @m_stream = a_stream
      @m_queue = a_queue
      @m_restart_on_exception = a_bool_restart_on_exception
      @m_sleep_ms = 1.0 / 1000.0 * Float(a_sleep_ms)
    end

    def run
      it = @m_stream.iterator()
      begin
        while it.hasNext()
          begin
            @m_queue << it.next().message()
          end
        end
      rescue Exception => e
        puts("#{self.class.name} caught exception: #{e.class.name}")
        puts(e.message) if e.message != ''
        if @m_restart_on_exception
          sleep(@m_sleep_ms)
          retry
        else
          raise e
        end
      end
    end
end