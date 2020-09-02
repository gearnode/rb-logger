# Introduction
This document explain how to use the `rb-logger` library.

# Concept
## Hierarchical
The library enable hierarchical logging feature which os helpful to filter log
on complex application with many components.

## Formatting
The library expose `sprintf` formatting feature which help to format complex
log message.

## Data
The library enable to log `data` with the log message, which is helpful to add
context on the log (e.g. `http_status`, `processing_time`, etc.).

# Example
You can create a new logger with:
```ruby
logger = RbLogger.new_logger("myapp")
logger.info("starting application")
#=> {"ts":"2020-09-02T09:11:55Z","domain":"myapp","message":"starting application","level":"info"}
```

You can create a child logger with:
```ruby
logger = logger.new_child("pg")
logger.info("starting pg component")
#=> {"ts":"2020-09-02T09:15:34Z","domain":"myapp.pg","message":"starting pg component","level":"info"}
```
