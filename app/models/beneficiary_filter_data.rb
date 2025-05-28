class BeneficiaryFilterData < SimpleDelegator
  attr_reader :address_data_field_name

  def initialize(*, **options)
    super(*)
    @address_data_field_name = options[:address_data_field_name]
  end

  def address_fields
    @address_fields ||= fields.each_with_object({}) do |(_name, field), result|
      next unless field.field_definition.prefix&.address?

      result[field.name] = field
    end
  end

  def address_data_field
    fields = address_fields.values
    return unless fields.one?

    fields.first if fields.first.name == address_data_field_name
  end

  private

  def object
    __getobj__
  end
end
