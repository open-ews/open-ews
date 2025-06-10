class EmailUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return unless User.exists?(email: value)

    record.errors.add(attribute, options.fetch(:message, :taken))
  end
end
