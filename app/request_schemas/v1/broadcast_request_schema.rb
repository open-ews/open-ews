module V1
  class BroadcastRequestSchema < JSONAPIRequestSchema
    option :broadcast_state_machine, default: -> { BroadcastStateMachine.new }

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "broadcast")
        required(:attributes).value(:hash).schema do
          optional(:channels).array(:string).value(size?: 1).each do
            included_in?(Broadcast.channel.values)
          end
          optional(:channel).filled(Types::ChannelType, eql?: "voice_call")
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

    attribute_rule(:channels, :channel) do |attributes:, context:, **|
      context[:channels] = Array(attributes[:channels] || attributes[:channel])
      context[:channel_capabilities] = context[:channels].map { BroadcastChannelCapabilities.new(it) }
    end

    attribute_rule(:channels) do |context:, **|
      key.failure("is not supported") if key? && Array(context[:channels]).any? { account.supported_channels.exclude?(it) }
    end

    attribute_rule(:status) do |context:, **|
      next unless key?

      if Array(context[:channel_capabilities]).any? { it.deliverable? } && !account.configured_for_broadcasts?
        base.failure("Account not configured")
      end
    end

    attribute_rule(:beneficiary_filter).validate(contract: BeneficiaryFilter)
    attribute_rule(:beneficiary_filter) do |relationships:, context:, **|
      next if key? || relationships.key?(:beneficiary_groups) || Array(context[:channel_capabilities]).none? { it.deliverable? }

      key.failure("is missing")
    end

    attribute_rule(:audio_url) do |context:, **|
      next key.failure("is missing") if value.blank? && Array(context[:channel_capabilities]).any? { it.audio? }
      next key.failure("is not allowed") if value.present? && Array(context[:channel_capabilities]).none? { it.audio? }
    end

    attribute_rule(:message) do |context:, **|
      next key.failure("is missing") if value.blank? && Array(context[:channel_capabilities]).any? { it.text? }
      next key.failure("is not allowed") if value.present? && Array(context[:channel_capabilities]).none? { it.text? }
    end

    attribute_rule(:audio_url).validate(:url_format)

    relationship_rule(:beneficiary_groups).validate(:beneficiary_groups)

    def output
      output_data = super
      result = output_data.slice(:message, :audio_url, :beneficiary_filter, :metadata)

      result[:channel] = context[:channels].first
      result[:beneficiary_group_ids] = Array(output_data[:beneficiary_groups])
      result[:desired_status] = broadcast_state_machine.transition_to!(output_data.fetch(:status)).name if output_data.key?(:status)
      result[:created_via] = :api
      result
    end
  end
end
