KAFKA_CONSUMER_OPTIONS = {
    :bootstrap_servers => '127.0.0.1:9092',
    :group_id=> 'test',
    :enable_auto_commit => 'true',
    :auto_commit_interval_ms => '1000',
    :session_timeout_ms => '30000',
    :key_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer',
    :value_deserializer => 'org.apache.kafka.common.serialization.StringDeserializer'
}
