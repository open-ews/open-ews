class BeneficiaryAddress < ApplicationRecord
  extend Enumerize

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze
  attribute :beneficiary_address_validator, default: -> { BeneficiaryAddressValidator.new }

  belongs_to :beneficiary, inverse_of: :addresses

  validates :iso_region_code, presence: true

  validates :iso_region_code,
    :administrative_division_level_2_code,
    :administrative_division_level_2_name,
    :administrative_division_level_3_code,
    :administrative_division_level_3_name,
    :administrative_division_level_4_code,
    :administrative_division_level_4_name,
    length: { maximum: 255 }

  validate :validate_address

  private

  def validate_address
    return if beneficiary_address_validator.valid?(attributes)

    beneficiary_address_validator.errors.each do |error|
      errors.add(error.key, :blank)
    end
  end
end
