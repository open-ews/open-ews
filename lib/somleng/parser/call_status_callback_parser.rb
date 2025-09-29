module Somleng
  module Parser
    class CallStatusCallbackParser
      def parse(payload)
        Somleng::Resource.new(
          sid: payload.fetch("CallSid"),
          to: payload.fetch("To"),
          from: payload.fetch("From"),
          account_sid: payload.fetch("AccountSid"),
          status: payload.fetch("CallStatus"),
          call_duration: payload.fetch("CallDuration").to_i,
          sip_response_code: payload.fetch("SipResponseCode")
        )
      end
    end
  end
end
