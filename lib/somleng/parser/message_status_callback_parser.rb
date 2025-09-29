module Somleng
  module Parser
    class MessageStatusCallbackParser
      def parse(payload)
        Somleng::Resource.new(
          sid: payload.fetch("MessageSid"),
          to: payload.fetch("To"),
          from: payload.fetch("From"),
          account_sid: payload.fetch("AccountSid"),
          status: payload.fetch("MessageStatus"),
          call_duration: nil,
          sip_response_code: nil
        )
      end
    end
  end
end
