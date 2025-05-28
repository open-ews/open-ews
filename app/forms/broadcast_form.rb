class BroadcastForm
  class BeneficiaryFilterForm
    class AddressFieldForm < FilterFieldForm; end

    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :gender, FormType.new(form: FilterFieldForm)
    attribute :disability_status, FormType.new(form: FilterFieldForm)
    attribute :date_of_birth, FormType.new(form: FilterFieldForm)
    attribute :iso_language_code, FormType.new(form: FilterFieldForm)
    attribute :iso_country_code, FormType.new(form: FilterFieldForm)
    attribute :iso_region_code, FormType.new(form: FilterFieldForm)
    attribute :administrative_division_level_2_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_2_name, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_3_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_3_name, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_4_code, FormType.new(form: AddressFieldForm)
    attribute :administrative_division_level_4_name, FormType.new(form: AddressFieldForm)

    delegate :human_attribute_name, to: :class

    def self.model_name
      ActiveModel::Name.new(self, nil, "BeneficiaryFilter")
    end

    def self.form_attributes
      attribute_names.each_with_object({}) do |name, result|
        type = type_for_attribute(name)
        next if type.options[:hidden]

        result[name] = type
      end
    end
  end

  class BeneficiaryFilterFormType < ActiveRecord::Type::Value
    def cast(value)
      return value if value.is_a?(BeneficiaryFilterForm)

      BeneficiaryFilterForm.new(value.is_a?(FilterData) ? cast_filter_data(value) : cast_form_params(value))
    end

    def serialize(value)
      return value unless value.is_a?(BeneficiaryFilterForm)

      fields = value.attributes.each_with_object({}) do |(name, filter), result|
        next if filter.blank?

        field_definition = FieldDefinitions::BeneficiaryFields.find_by!(name:)
        result[field_definition.name] = FilterData::Field.new(
          field_definition:,
          name: field_definition.name,
          operator: FilterData::Operator.new(
            name: filter.operator,
          ),
          value: FilterData::Value.new(
            actual_value: filter.value,
            human_value: nil
          )
        )
      end

      FilterData.new(fields:)
    end

    private

    def cast_form_params(params)
      params.each_with_object({}) do |(name, filter), result|
        result[name] = {
          operator: filter.with_indifferent_access.fetch(:operator),
          value: filter.with_indifferent_access.fetch(:value)
        }
      end
    end

    def cast_filter_data(filter_data)
      filter_data.fields.each_with_object({}) do |(name, field), result|
        result[name] = {
          operator: field.operator.name,
          value: field.value.actual_value
        }
      end
    end
  end

  extend Enumerize

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account, default: -> { Account.new }
  attribute :channel
  attribute :audio_file
  attribute :beneficiary_filter, BeneficiaryFilterFormType.new, default: -> { BeneficiaryFilterForm.new }
  attribute :object, default: -> { Broadcast.new }

  enumerize :channel, in: Broadcast::CHANNELS, default: :voice

  delegate :id, :new_record?, :persisted?, to: :object

  validates :audio_file, presence: true, if: :new_record?
  validates :channel, :beneficiary_filter, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Broadcast")
  end

  def self.initialize_with(broadcast)
    new(
      object: broadcast,
      channel: broadcast.channel,
      audio_file: broadcast.audio_file,
      beneficiary_filter: broadcast.beneficiary_filter
    )
  end

  def save
    return false if invalid?

    object.channel = channel
    object.audio_file = audio_file
    object.account ||= account
    object.beneficiary_filter = BeneficiaryFilterFormType.new.serialize(beneficiary_filter)

    object.save!
  end
end
