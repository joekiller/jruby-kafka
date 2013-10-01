require "java"
require "jruby-kafka/namespace"

java_import 'kafka.consumer.ConsumerIterator'
java_import 'kafka.consumer.KafkaStream'

class Kafka::Consumer
  include Java::JavaLang::Runnable
  java_signature 'void run()'

  @m_stream
  @m_threadNumber

    def initialize(a_stream, a_threadNumber)
      @m_threadNumber = a_threadNumber
      @m_stream = a_stream
    end

    def run()
      it = @m_stream.iterator()
      while it.hasNext()
        puts("Thread #{@m_threadNumber}: #{it.next().message()}")
      end
      puts("Shutting down Thread: #{@m_threadNumber}")
      end
end