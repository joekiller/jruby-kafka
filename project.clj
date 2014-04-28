(defproject
  jruby-kafka "jar"
  :description "Java requirements for jruby-kafka"
  :license     {:name "Apache License"
                :url "http://www.apache.org/licenses/"}
  :min-lein-version  "2.0.0"
  :dependencies   [[org.apache.kafka/kafka_2.10 "0.8.1"
                    :exclusions [com.sun.jdmk/jmxtools
                                 com.sun.jmx/jmxri]]]
  :target-path       "target")
