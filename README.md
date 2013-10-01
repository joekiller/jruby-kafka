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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[Kafka 0.8beta1 high level consumer](http://kafka.apache.org/documentation.html#highlevelconsumerapi)
[Kafka Consumer Group Example](https://cwiki.apache.org/confluence/display/KAFKA/Consumer+Group+Example)
