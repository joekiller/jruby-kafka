Gem::Specification.new do |spec|
  files = []
  dirs = %w{ lib }
  dirs.each do |dir|
    files += Dir["#{dir}/**/*"]
  end

  spec.name          = "jruby-kafka"
  spec.version       = "0.0.4"
  spec.authors       = ["Joseph Lawson"]
  spec.email         = ["joe@joekiller.com"]
  spec.description   = "this is primarily to be used as an interface for logstash"
  spec.summary       = "jruby Kafka wrapper"
  spec.homepage      = "https://github.com/joekiller/jruby-kafka"
  spec.license       = "Apache 2.0"

  spec.files         = files
  spec.require_paths << "lib"

end
