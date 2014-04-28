# Because of a problem with a kafka dependency, jbundler 0.5.5 does not work. Therefore, you
# need to do one of the following to have your Kafka jar dependencies available:
#
# - run your app under jbundler (adds a layer to bundler to manage jar dependencies)
# - already have the Kafka jars loaded before requiring jruby-kafka
# - set KAFKA_PATH in the environment to point to a Kafka binary installation
#
if not JBUNDLER_CLASSPATH and ENV['KAFKA_PATH']
  require 'jruby-kafka/loader'
end

require "jruby-kafka/consumer"
require "jruby-kafka/group"
require "jruby-kafka/producer"

module Kafka
end
