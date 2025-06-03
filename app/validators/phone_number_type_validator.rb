class PhoneNumberTypeValidator < ActiveModel::EachValidator
  attr_reader :validator

  def initialize(*, **options)
    super(*)
    @validator = options.fetch(:validator) { PhoneNumberValidator.new }
  end

  def validate_each(record, attribute, value)
    return record.errors.add(attribute, :blank) if value.blank?
    return if validator.valid?(value)

    record.errors.add(attribute, :invalid)
  end
end
