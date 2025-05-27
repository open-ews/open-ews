class BroadcastDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Broadcast
  end

  BeneficiaryFilter = Data.define(:fields, :address_fields, :address_data_field, :display_address_tree?)
  Field = Data.define(:name, :human, :operator, :value, :definition)
  Operator = Data.define(:name, :human)
  Value = Data.define(:actual, :human)

  def beneficiary_filter
    @beneficiary_filter ||= parse_beneficiary_filter
  end

  private

  def object
    __getobj__
  end

  def translatable_values
    Beneficiary.enumerized_attributes.attributes
  end

  def country
    object.account.iso_country_code
  end

  def parse_beneficiary_filter
    fields = object.beneficiary_filter.each_with_object([]) do |(key, filter), result|
      operator, value = filter.first

      result << Field.new(
        name: key,
        definition: FieldDefinitions::BeneficiaryFields.find_by!(path: key),
        human: self.class.human_attribute_name(key),
        operator: Operator.new(
          name: operator,
          human: I18n.t("filter_operators.#{operator}")
        ),
        value: Value.new(
          actual: value,
          human: translatable_values.include?(key) ? translatable_values.fetch(key).values.find { it == value }&.text || value : value
        )
      )
    end

    address_fields = fields.select { it.definition.prefix&.address? }
    address_data_field = address_fields.first if address_fields.one? && address_fields.first.name.to_sym == CountryAddressData.address_field_name(country)

    BeneficiaryFilter.new(
      fields:,
      address_fields:,
      address_data_field:,
      display_address_tree?: address_data_field.present?
    )
  end
end
