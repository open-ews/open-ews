class ArrayInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? && options[:allow_nil]
    return if Array(value).all? { options.fetch(:in).map(&:to_s).include?(it.to_s) }

    record.errors.add(attribute, :inclusion)
  end
end
