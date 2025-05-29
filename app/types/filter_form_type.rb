class FilterFormType < FormType
  attr_reader :field_definitions, :filter_data

  def initialize(field_definitions:, filter_data:, **)
    @field_definitions = field_definitions
    @filter_data = filter_data
    super(**)
  end

  def cast(value)
    return value if value.is_a?(form)

    form.new(value.is_a?(filter_data) ? cast_filter_data(value) : cast_form_params(value))
  end

  def serialize(value)
    return value unless value.is_a?(form)

    value.attributes.each_with_object({}) do |(name, filter), result|
      next if filter.blank?

      field_definition = field_definitions.find_by!(name:)
      result[field_definition.path] = { filter.operator => filter.value }
    end
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
    filter_data.data.fields.each_with_object({}) do |(name, field), result|
      result[name] = {
        operator: field.operator,
        value: field.value
      }
    end
  end
end
