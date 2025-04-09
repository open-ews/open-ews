module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    option :broadcast_status_validator, default: -> { BroadcastStatusValidator.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          required(:channel).filled(:str?, included_in?: Broadcast.channel.values)
          required(:audio_url).filled(:string)
          required(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(:str?, eql?: "running")
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:audio_url).validate(:url_format)

    def output
      result = super
      result[:desired_status] = broadcast_status_validator.transition_to!(result.delete(:status)).name if result.key?(:status)
      result
    end
  end
end
