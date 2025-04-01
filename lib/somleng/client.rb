module Somleng
  class Client
    class RestError < StandardError; end

    attr_reader :rest_client

    def initialize(**options)
      @rest_client = options.fetch(:rest_client) { Somleng::REST::Client.new(options.fetch(:account_sid), options.fetch(:auth_token)) }
    end

    def create_call(...)
      rest_client.calls.create(...)
    rescue Twilio::REST::RestError => e
      raise RestError.new(e.message)
    end
  end
end
