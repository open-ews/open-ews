module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    option :broadcast_status_validator, default: -> { BroadcastStateMachine.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          required(:channel).filled(:str?, included_in?: Broadcast.channel.values)
          required(:audio_url).filled(:string)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(:str?, eql?: "running")
          optional(:metadata).value(:hash)
        end

        optional(:relationships).value(:hash).schema do
          optional(:beneficiary_groups).value(:hash).schema do
            required(:data).array(:hash) do
              required(:type).filled(:str?, eql?: "beneficiary_group")
              required(:id).filled(:int?)
            end
          end
        end
      end
    end

    attribute_rule(:status).validate(:broadcast_status)
    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:beneficiary_filter) do |relationships:, **|
      next if key? || relationships.key?(:beneficiary_groups)

      key.failure("is missing")
    end

    attribute_rule(:audio_url).validate(:url_format)

    relationship_rule(:beneficiary_groups).validate(:beneficiary_groups)

    def output
      result = super
      result[:beneficiary_group_ids] = Array(result.delete(:beneficiary_groups))
      result[:desired_status] = broadcast_status_validator.transition_to!(result.delete(:status)).name if result.key?(:status)
      result
    end
  end
end
