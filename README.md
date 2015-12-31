# Jruby::Kafka

## Prerequisites

* [Apache Kafka] version 0.8.2.2 installed and running.

* [JRuby] installed.

[Apache Kafka]: http://kafka.apache.org/
[JRuby]: http://jruby.org/

## About

This gem is primarily used to wrap most of the [Kafka 0.8.2.2 high level consumer] and [Kafka 0.8.2.2 producer] API into
jruby.
The [Kafka Consumer Group Example] is pretty much ported to this library.

  - [Kafka 0.8.2.x high level consumer](http://kafka.apache.org/082/documentation.html#highlevelconsumerapi)
  - [Kafka 0.8.2.x java producer](http://kafka.apache.org/082/javadoc/index.html?org/apache/kafka/clients/producer/KafkaProducer.html)
  - [Kafka 0.8.2.x scala producer](http://kafka.apache.org/082/documentation.html#producerapi)
  - [Kafka Consumer Group Example](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example)
  
Note that the Scala `Kafka::Producer` will deprecate and Java `Kafka::KafkaProducer` is taking over. 

## Installation

This package is now distributed via [RubyGems.org](http://rubygems.org) but you can build it using the following instructions.

From the root of the project run:

    $ bundle install
    $ rake setup jar package

You can run the following to install the resulting package:

    $ gem install jruby-kafka*.gem

Add this line to your application's Gemfile:

    gem 'jruby-kafka'

## Usage

If you want to run the tests, make sure you already have downloaded Kafka 0.8.X, followed the [kafka quickstart]
instructions and have KAFKA_PATH set in the environment.

[kafka quickstart]: http://kafka.apache.org/documentation.html#quickstart

#### Usage

The following producer code sends a message to a `test` topic.

```ruby
require 'jruby-kafka'

producer_options = {:broker_list => "localhost:9092", "serializer.class" => "kafka.serializer.StringEncoder"}

producer = Kafka::Producer.new(producer_options)
producer.connect()
producer.send_msg("test", nil, "here's a test message")    
```

The following consumer example is the Ruby equivalent of the Kafka high-level consumer group example. It listens for 10 seconds to the `test` topic and prints out messages as they are received from Kafka in two threads.  The `test` topic should have at least two partitions for each thread to receive messages.

```ruby
require 'jruby-kafka'

consumer_options = {
  zookeeper_connect:  'localhost:2181',
  group_id:           'my_consumer_group',
  topic:              'test',
  num_streams:        2,
  auto_offset_reset:  "smallest"
}

consumer = Kafka::Consumer.new(consumer_options)

def consumer_test(stream, thread_num)
  it = stream.iterator
  puts "Thread #{thread_num}: #{it.next.message.to_s}" while it.hasNext 
  puts "Shutting down Thread: #{thread_num}"
end

streams  = consumer.message_streams
streams.each_with_index do |stream, thread_num|
  Thread.new { consumer_test stream, thread_num }
end

sleep 10
consumer.shutdown
```

#### Using in logstash:

Check out this repo: https://github.com/joekiller/logstash-kafka

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

