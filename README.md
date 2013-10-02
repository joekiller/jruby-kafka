# Jruby::Kafka

This gem is primarily used to wrap most of the [Kafka 0.8beta1 high level consumer] API into jruby.
The [Kafka Consumer Group Example] is pretty much ported to this library.

## Installation

Add this line to your application's Gemfile:

    gem 'jruby-kafka'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jruby-kafka

## Usage

If you want to run the tests, make sure you already have downloaded Kafka 0.8beta1 and have KAFKA_PATH set in the
environment.

Using in logstash:

from the logstash root:

set JRUBY_KAFKA_HOME to the root of this repo.

make clean && bin/logstash deps && $(cd $JRUBY_KAFKA_HOME && rake package) && gem install $JRUBY_KAFKA_HOME/jruby-kafka-0.0.1.gem -i vendor/bundle/jruby/1.9 && bin/logstash deps && make vendor-elasticsearch && cp $KAFKA_HOME/core/target/scala-2.8.0/*.jar vendor/jar &&  make flatjar && cd build && java -jar logstash-1.2.2.dev-flatjar.jar agent -f kafkatest.conf

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[Kafka 0.8beta1 high level consumer](http://kafka.apache.org/documentation.html#highlevelconsumerapi)
[Kafka Consumer Group Example](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example)
