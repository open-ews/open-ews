class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ Devise.email_regexp

    record.errors.add(attribute, options.fetch(:message, :invalid))
  end
end
