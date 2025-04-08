module Somleng
  module REST
    class API < Twilio::REST::Api
      def initialize(...)
        super
        @base_url = "https://api.somleng.org"
        @host = "api.somleng.org"
      end
    end
  end
end
