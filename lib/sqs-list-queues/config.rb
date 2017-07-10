module SqsListQueues

  class Config
    # Stronger builder pattern would be nice
    attr_accessor :client_options, :sqs_client,
      :patterns,
      :show_counts,
      :show_arn,
      :show_url,
      :json_format

    def initialize
      @client_options = {}
      @patterns = nil
      @show_counts = false
      @show_arn = false
      @show_url = false
      @json_format = false
    end

    def validate
      unless @json_format
        if @show_arn and @show_url
          raise "Can't show both ARN and URL unless JSON format is selected"
        end
      end
    end
  end

end
