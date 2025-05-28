class FormDataType < ActiveRecord::Type::String
  def cast(value)
    return value unless value.is_a?(Array)

    value.reject(&:blank?)
  end
end
