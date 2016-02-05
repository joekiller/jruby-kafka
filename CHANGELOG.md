#3.0 (February 05, 2016)
##general
- Make CI tests work. (#39)
- Upgrade to Kafka 0.9.0.
- Fix typos in README. (#41) Thank you @jeroenj.
- Upgrade jar-dependencies to make jars setup only in development. (https://github.com/mkristian/jar-dependencies/issues/38)

#2.0 (December 31, 2015)

##general
- Updated integration tests to support new consumer.
- Updated documentation to better reference Kafka 0.8.2.2.

##consumer
- Simplified for better parallelism. (#33) Thank you @eliaslevy.

##producer
- Updated to now support send callback. (#31) Thank you @eliaslevy.
- Fixed callback block variable throwing error when not defined. (#37) Thank you @ashangit.

#1.5.0 (December 31, 2015)

##general
- Updated to support Kafka 0.8.2.2. (#37) Thank you @ashangit.
- Fixed typos in README. (#35) Thank you @Ben-M.
- updated producer example and github code styling. (#26) Thank you @aliekens.
- Imporoved consumer exampled in README. (#27) Thank you @arcz.

#1.4.0 (March 22, 2015)

##consumer
- add key/value decoder options to Group for dynamically using custom decoder for consuming kafka messages. (#23) Thank you @talevy.

#1.1.2 (February 27, 2015)
#1.1.1 (February 25, 2015)
#1.1.0 (February 23, 2015)
#0.2.1 (September 22, 2014)
##producer
- fixed argument parser including nil options
- updated compressed.topics to take an array and transform it into comma separated list.
- removed compressed.topics parsing log fallacy.
- tons of inspection/style fixes

#0.2.0 (September 20, 2014)
##producer
- exposed close method to producer for cleanup in async threads.

#0.1.3 (September 15, 2014)
##producer
- clean up producer config to better match Kafka 0.8.x

#0.1.2 (September 11, 2014)
## general
- fixed up new loader class to load jars if invoked.

#0.1.0 (April 16, 2014)
## producer
- implemented remaining producer config variables.
- changed serializer.class from `kafka.serializer.StringEncoder` to nil which will result in it being the `kafka.serializer.DefaultEncoder` which is a byte stream.

## consumer
- added consumer_id

#0.0.12 (January 23, 2014)
## producer
- added support for compression_codec and compressed_topics

#0.0.11 (January 17, 2014)
## general
- cleaned up producer to remove unnecessary code

#0.0.10 (January 13, 2014)
## general
- first time using changelog
- added preliminary producer from pull request, thank you squito (https://github.com/joekiller/jruby-kafka/pull/1)
- updated to README.md to reference Kafka 0.8.0 release.
