module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    option :broadcast_state_machine, default: -> { BroadcastStateMachine.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          required(:channel).filled(Types::ChannelType, included_in?: Broadcast.channel.values)
          optional(:audio_url).maybe(:str?)
          optional(:message).maybe(:str?)
          optional(:beneficiary_filter).filled(:hash).schema(BeneficiaryFilter.schema)
          optional(:status).filled(:str?, eql?: "running")
          optional(:metadata).value(:hash)
        end

        optional(:relationships).value(:hash).schema do
          optional(:beneficiary_groups).value(:hash).schema do
            required(:data).value(:array, max_size?: Broadcast::MAX_BENEFICIARY_GROUPS).each do
              schema do
                required(:type).filled(:str?, eql?: "beneficiary_group")
                required(:id).filled(:int?)
              end
            end
          end
        end
      end
    end

    attribute_rule(:channel) do |context:, **|
      key.failure("is not supported") if key? && account.supported_channels.exclude?(value)
      context[:channel_capabilities] = BroadcastChannelCapabilities.new(value)
    end

    attribute_rule(:status) do |context:, **|
      next unless key?
      if context[:channel_capabilities]&.deliverable? && !account.configured_for_broadcasts?
        base.failure("Account not configured")
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:beneficiary_filter) do |relationships:, context:, **|
      next if key? || relationships.key?(:beneficiary_groups) || !context[:channel_capabilities]&.deliverable?

      key.failure("is missing")
    end

    attribute_rule(:audio_url) do |context:, **|
      next key.failure("is missing") if value.blank? && context[:channel_capabilities]&.audio?
      next key.failure("is not allowed") if value.present? && !context[:channel_capabilities]&.audio?
    end

    attribute_rule(:message) do |context:, **|
      next key.failure("is missing") if value.blank? && context[:channel_capabilities]&.text?
      next key.failure("is not allowed") if value.present? && !context[:channel_capabilities]&.text?
    end

    attribute_rule(:audio_url).validate(:url_format)

    relationship_rule(:beneficiary_groups).validate(:beneficiary_groups)

    def output
      result = super
      result[:beneficiary_group_ids] = Array(result.delete(:beneficiary_groups))
      result[:desired_status] = broadcast_state_machine.transition_to!(result.delete(:status)).name if result.key?(:status)
      result[:created_via] = :api
      result
    end
  end
end
