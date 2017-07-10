module SqsListQueues

  class Lister

    # ListQueues /seems/ to return the queues in ASCII order (case sensitive).
    # The following algorithm depends on this assumption.

    # Allowed characters in SQS queue names, in that order (see above).
    ALPHABET = ("0".."9").to_a \
             + ["-"] \
             + ("A".."Z").to_a \
             + ["_"] \
             + ("a".."z").to_a

    # Ceiling of ListQueues results
    MAX_RESULTS = 1000

    def initialize(sqs_client)
      @sqs_client = sqs_client
    end

    def get_possibly_truncated_list(prefix)
      # $stderr.puts "Querying with prefix = #{prefix.inspect}"
      @sqs_client.list_queues(queue_name_prefix: prefix).queue_urls
    end

    def get_full_list(prefix = "")
      urls = get_possibly_truncated_list prefix

      if urls.count < MAX_RESULTS
        return urls
      end

      last_result = urls.last
      last_name = File.basename last_result

      # If prefix = "foo"
      # and the last result we have is "foolish"
      # then to discover things later than this, we have to use a longer prefix
      # then "foo":
      # - "foom", "foon" (etc, for all possible character after "l"), each of
      # which must be iterated independently
      # - but for "fool"... we can try "fool" (which will certainly return some
      # results we already have), and _may_ return additional results

      problematic_letter = last_name[prefix.length]

      # The fool case
      fool_names = get_full_list(prefix + problematic_letter)
      index_of_last_result = fool_names.index last_result
      fool_names = fool_names[index_of_last_result+1 .. -1]

      # The foom, foon... case
      problematic_index = ALPHABET.index problematic_letter
      remaining_letters = ALPHABET[problematic_index+1 .. -1]

      remaining_names = remaining_letters.map do |letter|
        get_full_list(prefix + letter)
      end

      (urls + fool_names + remaining_names).flatten
    end

  end

end
