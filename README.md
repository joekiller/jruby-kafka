# Jruby::Kafka

## Prerequisites

* [Apache Kafka] version 0.8 beta 1 installed and running.

* [JRuby] installed.

[Apache Kafka]: http://kafka.apache.org/
[JRuby]: http://jruby.org/

## About

This gem is primarily used to wrap most of the [Kafka 0.8beta1 high level consumer] API into jruby.
The [Kafka Consumer Group Example] is pretty much ported to this library.

[Kafka 0.8beta1 high level consumer]: http://kafka.apache.org/documentation.html#highlevelconsumerapi
[Kafka Consumer Group Example]: https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example

## Installation

This isn't distributed yet so you have to build the gem first.  From the root of the project run:

    $ rake package

You can run the following to install the resulting package:

    $ gem install jruby-kafka*.gem

Add this line to your application's Gemfile:

    gem 'jruby-kafka'

## Usage

If you want to run the tests, make sure you already have downloaded Kafka 0.8beta1, followed the [kafka quickstart]
instructions and have KAFKA_PATH set in the environment.

[kafka quickstart]: http://kafka.apache.org/documentation.html#quickstart

Using in logstash:

from the logstash root:

set JRUBY_KAFKA_HOME to the root of this repo.

    make clean && \
    bin/logstash deps && \
    $(cd $JRUBY_KAFKA_HOME && rake package) && \
    gem install $JRUBY_KAFKA_HOME/jruby-kafka-0.0.1.gem -i vendor/bundle/jruby/1.9 && \
    bin/logstash deps && \
    make vendor-elasticsearch && \
    cp $KAFKA_HOME/core/target/scala-2.8.0/*.jar vendor/jar &&  \
    make flatjar && \
    cd build && \
    java -jar logstash-1.2.2.dev-flatjar.jar agent -f kafkatest.conf

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

