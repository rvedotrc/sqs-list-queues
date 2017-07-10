sqs-list-queues
===============

List SQS queues, optionally with message counts, queue URLs and ARNs.

Installation
------------

```
  gem build sqs-list-queues.gemspec
  gem install sqs-list-queues*.gem
```

Use
---

Examples:

```
  # List all queue names
  sqs-list-queues

  # List queues whose names start with either "Foo" or "Bar", showing queue
  # URLs not names:
  sqs-list-queues --url Foo Bar

  # List queues whose names start with "MyQueues", showing message counts:
  sqs-list-queues --counts MyQueues
```

More options are available; see `sqs-list-queues --help`.

sqs-list-queues can also be used as a Ruby library.  See `bin/sqs-list-queues`
for a guide for how to do this.

