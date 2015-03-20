Gem::Specification.new do |spec|

  spec.name          = 'jruby-kafka'
  spec.version       = '1.3.0'
  spec.authors       = ['Joseph Lawson']
  spec.email         = ['joe@joekiller.com']
  spec.description   = 'this is primarily to be used as an interface for logstash'
  spec.summary       = 'jruby Kafka wrapper'
  spec.homepage      = 'https://github.com/joekiller/jruby-kafka'
  spec.license       = 'Apache 2.0'
  spec.platform      = 'java'
  spec.require_paths = [ 'lib' ]

  spec.files = Dir[ 'lib/**/*.rb', 'lib/**/*.jar', 'lib/**/*.xml' ]

  #Jar dependencies
  spec.requirements << "jar 'org.apache.kafka:kafka_2.10', '0.8.2.1'"
  spec.requirements << "jar 'org.slf4j:slf4j-log4j12', '1.7.10'"

  # Gem dependencies
  spec.add_runtime_dependency 'jar-dependencies', '~> 0'
  spec.add_runtime_dependency 'ruby-maven', '~> 3.1'

  spec.add_development_dependency 'rake', '~> 10.4'
end
