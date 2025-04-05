module Somleng
  module Parser
    class CallStatusCallbackParser
      def parse(payload)
        Somleng::CallStatusCallback.new(
          call_sid: payload.fetch("CallSid"),
          to: payload.fetch("To"),
          from: payload.fetch("From"),
          direction: payload.fetch("Direction"),
          account_sid: payload.fetch("AccountSid"),
          call_status: payload.fetch("CallStatus"),
          call_duration: payload.fetch("CallDuration").to_i
        )
      end
    end
  end
end
