module Somleng
  module REST
    class Client < Twilio::REST::Client
      def api
        @api ||= API.new(self)
      end
    end
  end
end
