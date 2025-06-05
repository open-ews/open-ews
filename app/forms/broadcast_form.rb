class BroadcastForm
  class BeneficiaryFilterForm < ApplicationForm
    class AddressFieldForm < FilterFieldForm; end

    attribute :gender, FormType.new(form: FilterFieldForm)
    attribute :disability_status, FormType.new(form: FilterFieldForm)
    attribute :date_of_birth, FormType.new(form: FilterFieldForm)
    attribute :iso_language_code, FormType.new(form: FilterFieldForm)
    attribute :created_at, FormType.new(form: FilterFieldForm)
    attribute :iso_country_code, FormType.new(form: FilterFieldForm)
    attribute :iso_region_code, FormType.new(form: FilterFieldForm)
    attribute :administrative_division_level_2_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_2_name, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_3_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_3_name, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_4_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_4_name, FormType.new(form: AddressFieldForm)
  end

  extend Enumerize

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account
  attribute :channel
  attribute :audio_file
  attribute :beneficiary_filter,
            FilterFormType.new(
              form:  BeneficiaryFilterForm,
              filter_data: BeneficiaryFilterData,
              field_definitions: FieldDefinitions::BeneficiaryFields
            ),
            default: -> { BeneficiaryFilterForm.new }

  attribute :object, default: -> { Broadcast.new }

  enumerize :channel, in: Broadcast::CHANNELS, default: :voice

  delegate :id, :new_record?, :persisted?, to: :object

  validates :audio_file, presence: true, if: :new_record?
  validates :channel, :beneficiary_filter, presence: true, if: :new_record?

  def self.model_name
    ActiveModel::Name.new(self, nil, "Broadcast")
  end

  def self.initialize_with(broadcast)
    new(
      object: broadcast,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file,
      beneficiary_filter: BeneficiaryFilterData.new(data: broadcast.beneficiary_filter)
    )
  end

  def save
    return false if invalid?

    object.channel = channel
    object.audio_file = audio_file if audio_file.present?
    object.account ||= account
    object.beneficiary_filter = FilterFormType.new(
      form: BeneficiaryFilterForm,
      filter_data: BeneficiaryFilterData,
      field_definitions: FieldDefinitions::BeneficiaryFields
    ).serialize(beneficiary_filter)

    object.save!
  end
end
