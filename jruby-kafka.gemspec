jruby_kafka_version = begin
  describe = `git describe --dirty`.strip
  describe_long  = `git describe --long --dirty`.strip
  if describe == describe_long
    version = describe.insert(describe.index(/-[0-9]*-/), '.ci')
  else
    version = describe
  end
  version[1..-1].tr('-', '.')
end

Gem::Specification.new do |s|
  s.name          = 'jruby-kafka'
  s.version       = jruby_kafka_version
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

  s.add_runtime_dependency 'concurrent-ruby', '< 2.0'

  s.add_development_dependency 'jar-dependencies', '~> 0.3.2'
  s.add_development_dependency 'rake', '~> 10.5'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'ruby-maven', '~> 3.3'
end
