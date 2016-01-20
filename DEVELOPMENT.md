#Coding

Prerequisites:

```
git clean -fd
export JARS_VENDOR=false
bundle install
rake clean
```

# Building

Get jars for gem build:

```
rake package
```

# Publishing
`gem push pkg/jruby-kafka*.gem`
