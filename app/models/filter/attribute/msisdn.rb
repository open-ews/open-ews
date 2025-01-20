module Filter
  module Attribute
    class Msisdn < Filter::Base
      def apply
        association_chain.where(msisdn: PhoneNumberType.new.cast(msisdn))
      end

      def apply?
        msisdn.present?
      end

      private

      def msisdn
        params[:msisdn]
      end
    end
  end
end
