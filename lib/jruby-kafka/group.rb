# basically we are porting this https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

require "java"

require "jruby-kafka/namespace"
require "jruby-kafka/consumer"

java_import 'java.util.concurrent.ExecutorService'
java_import 'java.util.consurrent.Executors'

class Kafka::Group
  @consumer
  @topic
  def initialize(a_zookeeper, a_groupId, a_topic)
    @consumer = Java::kafka::consumer::Consumer.createJavaConsumerConnector(createConsumerConfig(a_zookeeper,a_groupId))
    @topic = a_topic
  end

  private
  def createConsumerConfig(a_zookeeper,a_groupId)
    properties = java.util.Properties.new()
    properties.put("zookeeper.connect", a_zookeeper)
    properties.put("group.id", a_groupId)
    properties.put("zookeeper.session.timeout.ms", "400")
    properties.put("zookeeper.sync.time.ms", "200")
    properties.put("auto.commit.interval.ms", "1000")

    return Java::kafka::consumer::ConsumerConfig.new(properties)
  end
end
