module Filter
  module Resource
    class RemotePhoneCallEvent < Filter::Resource::Base
      def self.attribute_filters
        super << :details_attribute_filter <<
          :call_duration_attribute_filter
      end

      private

      def details_attribute_filter
        Filter::Attribute::JSON.new(
          { json_attribute: :details }.merge(options), params
        )
      end

      def call_duration_attribute_filter
        Filter::Attribute::Duration.new(
          { duration_column: :call_duration }.merge(options), params
        )
      end

      def filter_params
        result = params.slice(
          :phone_call_id,
          :delivery_attempt_id,
          :call_flow_logic,
          :remote_call_id,
          :remote_direction,
          :call_duration
        )

        result[:delivery_attempt_id] = result.delete(:phone_call_id) if result.key?(:phone_call_id)
        result
      end
    end
  end
end
