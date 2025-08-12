class BroadcastForm < ApplicationForm
  attribute :account
  attribute :channel
  attribute :audio_file
  attribute :message
  attribute :beneficiary_groups, FilledArrayType.new
  attribute :beneficiary_filter,
            FilterFormType.new(
              form:  BeneficiaryFilterForm,
              filter_data: BeneficiaryFilterData,
              field_definitions: FieldDefinitions::BeneficiaryFields
            ),
            default: -> { BeneficiaryFilterForm.new }

  attribute :object, default: -> { Broadcast.new }

  enumerize :channel, in: Broadcast.channel.values, default: ->(form) { form.supported_channels.first }

  delegate :id, :new_record?, :persisted?, to: :object
  delegate :supported_channels, to: :account

  validates :audio_file, presence: true, if: -> { new_record? && channel == "voice" }
  validates :message, presence: true, if: -> { channel == "sms" }
  validates :channel, presence: true, inclusion: { in: ->(form) { form.supported_channels } }, if: :new_record?
  validates :beneficiary_filter, presence: true, if: :new_record?
  validates :beneficiary_groups, length: { maximum: Broadcast::MAX_BENEFICIARY_GROUPS, allow_blank: true }

  def self.model_name
    ActiveModel::Name.new(self, nil, "Broadcast")
  end

  def self.initialize_with(broadcast)
    new(
      object: broadcast,
      account: broadcast.account,
      message: broadcast.message,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file,
      beneficiary_groups: broadcast.beneficiary_group_ids,
      beneficiary_filter: BeneficiaryFilterData.new(data: broadcast.beneficiary_filter)
    )
  end

  def save
    return false if invalid?

    object.channel = channel if new_record? && channel.present?
    object.message = message.presence if channel == "sms"
    object.audio_file = audio_file if audio_file.present?
    object.account ||= account
    object.beneficiary_group_ids = beneficiary_groups
    object.beneficiary_filter = FilterFormType.new(
      form: BeneficiaryFilterForm,
      filter_data: BeneficiaryFilterData,
      field_definitions: FieldDefinitions::BeneficiaryFields
    ).serialize(beneficiary_filter)

    object.save!
  end

  def beneficiary_groups_options_for_select
    account.beneficiary_groups
  end

  def channel_options_for_select
    BroadcastForm.channel.values.select { supported_channels.include?(it) }.map { [it.text, it] }
  end
end
