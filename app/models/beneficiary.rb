class Beneficiary < ApplicationRecord
  include MetadataHelpers

  attribute :phone_number, :phone_number
  attribute :address_administrative_division_codes, :string, array: true

  enumerize :status, in: [ :active, :disabled ], scope: :shallow
  enumerize :gender, in: [ "M", "F" ]
  enumerize :disability_status, in: [ :normal, :disabled ]
  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :account

  has_many :addresses, class_name: "BeneficiaryAddress", foreign_key: :beneficiary_id, inverse_of: :beneficiary, autosave: true
  has_many :group_memberships, class_name: "BeneficiaryGroupMembership"
  has_many :groups, through: :group_memberships, source: :beneficiary_group, class_name: "BeneficiaryGroup"
  has_many :notifications
  has_many :delivery_attempts

  validates :phone_number, presence: true, phone_number_type: true, uniqueness: { scope: :account_id }
  validates :iso_country_code, presence: true
  validates :iso_language_code, length: { is: 3, allow_blank: true }

  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank

  def self.jsonapi_serializer_class
    BeneficiarySerializer
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result
  end
end
