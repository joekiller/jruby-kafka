Gem::Specification.new do |s|

  s.name          = 'jruby-kafka'
  path            = File.expand_path('lib/jruby-kafka/version.rb', File.dirname(__FILE__))
  s.version       = File.read(path).match( /\s*VERSION\s*=\s*['"](.*)['"]/ )[1]
  s.authors       = ['Joseph Lawson']
  s.email         = ['joe@joekiller.com']
  s.description   = 'A ready to go interface to Kafka for JRuby.'
  s.summary       = 'jruby Kafka wrapper'
  s.homepage      = 'https://github.com/joekiller/jruby-kafka'
  s.license       = 'Apache 2.0'
  s.platform      = 'java'
  s.require_paths = [ 'lib' ]

  s.files = Dir[ 'lib/**/*.rb', 'lib/**/*.jar', 'lib/**/*.xml' ]
  s.test_files    = `git ls-files -- {test}/*`.split("\n")

  #Jar dependencies
  s.requirements << "jar 'org.apache.kafka:kafka_2.11', '0.9.0.1'"
  s.requirements << "jar 'org.slf4j:slf4j-log4j12', '1.7.13'"

  s.add_runtime_dependency "concurrent-ruby", "1.0.0"

  s.add_development_dependency 'jar-dependencies', "~> #{File.read(path).match( /\s*JAR_DEPENDENCIES_VERSION\s*=\s*['"](.*)['"]/ )[1]}"
  s.add_development_dependency 'rake', '~> 10.5'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'ruby-maven', '~> 3.3'
end
