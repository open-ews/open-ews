class FormDataType < ActiveRecord::Type::String
  def cast(value)
    case value
    when Array
      value.reject(&:blank?)
    when String
      value.presence
    else
      value
    end
  end
end
