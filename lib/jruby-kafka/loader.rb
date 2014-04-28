module Kafka
  def self.load_jars(kafka_path = nil)
    kafka_path ||= ENV['KAFKA_PATH']

    raise 'Please set KAFKA_PATH' unless kafka_path
    dir = File.join(kafka_path, 'libs')
    jars = Dir.glob(File.join(dir, '*.jar'))
    raise "KAFKA_PATH set, but #{dir} contains no jar files." if jars.empty?
    jars.each { |jar| require jar }
  end
end

