module Somleng
  module Parser
    class MessageResourceParser
      def parse(response)
        Somleng::Resource.new(
          sid: response.sid,
          to: response.to,
          from: response.from,
          account_sid: response.account_sid,
          status: response.status,
          call_duration: nil,
          sip_response_code: nil
        )
      end
    end
  end
end
