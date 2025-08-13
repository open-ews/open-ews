module Somleng
  class Client
    class RestError < StandardError; end

    attr_reader :rest_client

    def initialize(**options)
      @rest_client = options.fetch(:rest_client) { Somleng::REST::Client.new(options.fetch(:account_sid), options.fetch(:auth_token)) }
    end

    def create_call(...)
      make_request(parser: Somleng::Parser::CallResourceParser.new) do
        rest_client.calls.create(...)
      end
    end

    def create_message(...)
      make_request(parser: Somleng::Parser::MessageResourceParser.new) do
        rest_client.messages.create(...)
      end
    end

    def fetch_call(call_sid)
      make_request(parser: Somleng::Parser::CallResourceParser.new) do
        rest_client.calls(call_sid).fetch
      end
    end

    def fetch_message(message_sid)
      make_request(parser: Somleng::Parser::MessageResourceParser.new) do
        rest_client.messages(message_sid).fetch
      end
    end

    private

    def make_request(parser:)
      parser.parse(yield)
    rescue Twilio::REST::RestError => e
      raise RestError.new(e.message)
    end
  end
end
