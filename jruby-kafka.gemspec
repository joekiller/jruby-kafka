Gem::Specification.new do |spec|
  files = []
  dirs = %w{ lib }
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name          = 'jruby-kafka'
  spec.version       = '0.2.1'
  spec.authors       = ['Joseph Lawson']
  spec.email         = ['joe@joekiller.com']
  spec.description   = 'this is primarily to be used as an interface for logstash'
  spec.summary       = 'jruby Kafka wrapper'
  spec.homepage      = 'https://github.com/joekiller/jruby-kafka'
  spec.license       = 'Apache 2.0'
  spec.platform      = 'java'

  spec.files         = files
  spec.require_paths << 'lib'

  spec.add_dependency 'jbundler'
  spec.requirements << "jar 'org.apache.kafka:kafka_2.9.2', '0.8.1.1'"
  spec.requirements << "jar 'org.slf4j:slf4j-log4j12', '1.7.5'"
end
