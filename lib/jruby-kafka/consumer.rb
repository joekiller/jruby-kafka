require "java"
require "jruby-kafka/namespace"

java_import 'kafka.consumer.ConsumerIterator'
java_import 'kafka.consumer.KafkaStream'

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
        @m_queue << it.next().message()
      end
    end
end