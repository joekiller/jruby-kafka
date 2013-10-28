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

    def initialize(a_stream, a_threadNumber, a_queue)
      @m_threadNumber = a_threadNumber
      @m_stream = a_stream
      @m_queue = a_queue
    end

    def run
      it = @m_stream.iterator()
      while it.hasNext()
        begin
          begin
            @m_queue << it.next().message()
          rescue ConsumerRebalanceFailedException => e
            raise KafkaError.new(e), "Got ConsumerRebalanceFailedException: #{e}"
          rescue ConsumerTimeoutException => e
            raise KafkaError.new(e), "Got ConsumerTimeoutException: #{e}"
          end
        end
      end
    end
end