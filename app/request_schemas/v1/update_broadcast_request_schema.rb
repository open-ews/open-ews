module V1
  class UpdateBroadcastRequestSchema < JSONAPIRequestSchema
    VALID_STATES = [ "running", "stopped" ].freeze

    option :broadcast_status_validator, default: -> { BroadcastStatusValidator.new(resource.status) }

    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:audio_url).filled(:string)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(included_in?: VALID_STATES)
          optional(:metadata).value(:hash)
        end
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:audio_url).validate(:url_format)

    attribute_rule(:beneficiary_filter) do
      next unless key?
      next if broadcast_status_validator.may_transition_to?(:running)

      key.failure("cannot be updated after broadcast started")
    end

    attribute_rule(:audio_url) do
      next unless key?
      next if broadcast_status_validator.may_transition_to?(:running)

      key.failure("cannot be updated after broadcast started")
    end

    attribute_rule(:status) do |context:|
      next unless key?

      if broadcast_status_validator.may_transition_to?(value)
        context[:desired_status] = broadcast_status_validator.transition_to!(value).name
      else
        key.failure("cannot transition from #{resource.status} to #{value}")
      end
    end

    def output
      result = super
      result.delete(:status)
      result[:desired_status] = context.fetch(:desired_status) if context.key?(:desired_status)
      result
    end
  end
end
