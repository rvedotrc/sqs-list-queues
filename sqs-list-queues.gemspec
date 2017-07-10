lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqs-list-queues/version'

Gem::Specification.new do |s|
  s.name        = 'sqs-list-queues'
  s.version     = SqsListQueues::VERSION
  s.licenses    = [ 'Apache-2.0' ]
  s.date        = '2017-07-10'
  s.summary     = 'List SQS queues, optionally with message counts and more'
  s.description = '
    sqs-list-queues lists your SQS queues (working around the 1000 queue limit
    in the ListQueues API).

    Options are available to filter by queue name, show message counts, show
    queue ARNs and/or names, and output as json.

    Respects $https_proxy.
  '
  s.homepage    = 'https://github.com/rvedotrc/sqs-list-queues'
  s.authors     = ['Rachel Evans']
  s.email       = 'sqs-list-queues-git@rve.org.uk'

  s.executables = %w[
sqs-list-queues
  ]

  s.files       = %w[
lib/sqs-list-queues.rb
lib/sqs-list-queues/client.rb
lib/sqs-list-queues/config.rb
lib/sqs-list-queues/lister.rb
lib/sqs-list-queues/runner.rb
lib/sqs-list-queues/version.rb
  ] + s.executables.map {|s| "bin/"+s}

  s.require_paths = ["lib"]

  s.add_dependency 'aws-sdk', "~> 2.0"
  s.add_dependency 'rosarium', "~> 0.1"
end
