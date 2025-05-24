class BroadcastForm
  extend Enumerize

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :object, default: -> { Broadcast.new }

  attribute :channel
  attribute :audio_file
  attribute :beneficiary_filter,
    BeneficiaryFilterType.new,
    default: -> { BroadcastForm::BeneficiaryFilter.new }

  enumerize :channel, in: Broadcast::CHANNELS, default: :voice

  delegate :id, :new_record?, :persisted?, to: :object

  validates :audio_file, presence: true, if: :new_record?
  validates :channel, :beneficiary_filter, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Broadcast")
  end

  def self.initialize_with(broadcast, beneficiary_filter:)
    new(
      object: broadcast,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file,
      beneficiary_filter:
    )
  end

  def save
    return false if invalid?

    Broadcast.transaction do
      object.channel = channel
      object.audio_file = audio_file
      object.beneficiary_filter = BeneficiaryFilterType.new.serialize(
        beneficiary_filter
      )

      object.save!
    end
  end
end
