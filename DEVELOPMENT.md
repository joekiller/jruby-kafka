#Coding

Prerequisites:

`bundle install`

Get jars and generate jruby-kafka_jars.rb:

`rake setup jar`

# Building

Get jars for gem build:

`rake setup jar package`

Build gem:

`gem build jruby-kafka.gemspec`
