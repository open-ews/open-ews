class BeneficiaryFilterData < SimpleDelegator
  attr_reader :address_data_field_name

  def initialize(*, **options)
    super(*)
    @address_data_field_name = options[:address_data_field_name]
  end

  def address_fields
    @address_fields ||= fields.select { it.field_definition.prefix&.address? }
  end

  def address_data_field
    return unless address_fields.one?

    address_fields.first if address_fields.first.name == address_data_field_name
  end

  private

  def object
    __getobj__
  end
end
