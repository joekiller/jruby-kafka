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

[Kafka 0.8.2.2 high level consumer]: http://kafka.apache.org/documentation.html#highlevelconsumerapi
[Kafka 0.8.2.2 producer]: https://cwiki.apache.org/confluence/display/KAFKA/0.8.0+Producer+Example
[Kafka Consumer Group Example]: https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

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

#### Using in irb

make a producer

    require 'jruby-kafka'

    producer_options = {:topic_id => "test", :broker_list => "localhost:9092"}
    producer = Kafka::Producer.new(producer_options)
    producer.connect()
    producer.sendMsg(nil, "here's a test")


then a consumer

    require 'jruby-kafka'
    queue = SizedQueue.new(20)
    group = Kafka::Group.new(options)
    group.run(1,queue)
    Java::JavaLang::Thread.sleep 3000

    #just gets first 20 things & prints out
    until queue.empty?
      puts(queue.pop)
    end

    group.shutdown()



#### Using in logstash:

Check out this repo: https://github.com/joekiller/logstash-kafka

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

