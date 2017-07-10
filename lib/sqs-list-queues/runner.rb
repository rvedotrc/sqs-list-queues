require 'aws-sdk'
require 'json'
require 'rosarium'

module SqsListQueues

  class Runner

    def initialize(config)
      @config = config

      @config.sqs_client ||= begin
                               effective_options = SqsListQueues::Client.core_v2_options.merge(config.client_options)
                               Aws::SQS::Client.new(effective_options)
                             end
    end

    def promise
      promise_queue_urls.then do |queue_urls|
        Rosarium::Promise.all(queue_urls.map {|queue_url| promise_queue queue_url}.reject &:nil?)
      end
    end

    def promise_queue_urls
      prefixes = get_pattern_prefixes

      if prefixes.empty? or prefixes.any? {|prefix| prefix == ""}
        Rosarium::Promise.execute do
          SqsListQueues::Lister.new(@config.sqs_client).get_full_list
        end
      else
        Rosarium::Promise.all(
          prefixes.map do |prefix|
            Rosarium::Promise.execute do
              SqsListQueues::Lister.new(@config.sqs_client).get_full_list(prefix)
            end
          end
        ).then do |v|
          v.flatten.uniq
        end
      end
    end

    def get_pattern_prefixes
      if @config.patterns.nil?
        []
      else
        @config.patterns.map do |pattern|
          pattern.match(/^([0-9A-Za-z_-]*)/)[1]
        end
      end
    end

    def pattern_to_string_prefix(pattern)
      m = pattern.match /^/
    end

    def promise_queue(queue_url)
      queue_name = File.basename queue_url
      return nil unless name_matches_patterns?(queue_name)

      Rosarium::Promise.execute do
        r = {
          name: queue_name,
          url: queue_url,
        }

        required_attributes = []

        if @config.show_arn
          required_attributes << 'QueueArn'
        end

        if @config.show_counts
          required_attributes << 'ApproximateNumberOfMessages'
          required_attributes << 'ApproximateNumberOfMessagesNotVisible'
          required_attributes << 'ApproximateNumberOfMessagesDelayed'
        end

        unless required_attributes.empty?
          r[:attributes] = @config.sqs_client.get_queue_attributes(
            queue_url: queue_url,
            attribute_names: required_attributes,
          ).attributes
        end

        r
      end
    end

    def name_matches_patterns?(queue_name)
      return true if @config.patterns.nil?

      @config.patterns.any? do |pattern|
        queue_name.match("^" + pattern)
      end
    end

    def run
      promise.then do |queues|
        queues.each do |queue|
          if @config.json_format
            puts JSON.generate(queue)
          else
            if @config.show_counts
              msg = queue[:attributes]["ApproximateNumberOfMessages"]
              invis = queue[:attributes]["ApproximateNumberOfMessagesNotVisible"]
              delayed = queue[:attributes]["ApproximateNumberOfMessagesDelayed"]
              print "#{msg}\t#{invis}\t#{delayed}\t"
            end

            if @config.show_arn
              puts queue[:attributes]["QueueArn"]
            elsif @config.show_url
              puts queue[:url]
            else
              puts queue[:name]
            end
          end
        end
      end.value!

      return 0
    end

  end

end
