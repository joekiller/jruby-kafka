Gem::Specification.new do |spec|
  files = []
  dirs = %w{ lib }
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name          = "jruby-kafka"
  spec.version       = "0.1.3"
  spec.authors       = ["Joseph Lawson"]
  spec.email         = ["joe@joekiller.com"]
  spec.description   = "this is primarily to be used as an interface for logstash"
  spec.summary       = "jruby Kafka wrapper"
  spec.homepage      = "https://github.com/joekiller/jruby-kafka"
  spec.license       = "Apache 2.0"
  spec.platform      = "java"

  spec.files         = files
  spec.require_paths << "lib"

  spec.add_dependency 'jbundler', '0.5.5'
  spec.requirements << "jar 'org.apache.kafka:kafka_2.9.2', '0.8.1'"
  spec.requirements << "jar 'log4j:log4j', '1.2.14'"
end
