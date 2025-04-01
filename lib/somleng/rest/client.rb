module Somleng
  module REST
    class Client < Twilio::REST::Client
      def api
        @api ||= Api.new(self)
      end
    end
  end
end
