def consumer_test(stream, thread_num, queue)
  it = stream.iterator
  queue << it.next.message.to_s while it.hasNext
  puts "Shutting down Thread: #{thread_num}"
end

KAFKA_PRODUCER_OPTIONS = {
    :bootstrap_servers => '127.0.0.1:9092',
    :key_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
    :value_serializer => 'org.apache.kafka.common.serialization.StringSerializer',
}

PRODUCER_OPTIONS = {
    :broker_list => '127.0.0.1:9092',
    :serializer_class => 'kafka.serializer.StringEncoder'
}

CLIENT_OPTIONS = {
        :zookeeper_connect => '127.0.0.1:2181',
        :group_id => 'test',
        :topic => 'test'
}