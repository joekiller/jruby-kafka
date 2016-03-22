#Coding

Prerequisites:

```
git clean -fd
bundle install
rake install_jars
```

# Building

Get jars for gem build:

```
rake install_jars
gem build jruby-kafka.gemspec
```

# Publishing
`gem push jruby-kafka*.gem`
