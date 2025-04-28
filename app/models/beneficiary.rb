class Beneficiary < ApplicationRecord
  extend Enumerize

  include MetadataHelpers

  attribute :phone_number, :phone_number
  attribute :address_administrative_division_codes, :string, array: true

  enumerize :status, in: [ :active, :disabled ], scope: :shallow
  enumerize :gender, in: [ "M", "F" ]
  enumerize :disability_status, in: [ :normal, :disabled ]
  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :account

  has_many :addresses, class_name: "BeneficiaryAddress", foreign_key: :beneficiary_id
  has_many :group_memberships, class_name: "BeneficiaryGroupMembership"
  has_many :groups, through: :group_memberships, source: :beneficiary_group, class_name: "BeneficiaryGroup"
  has_many :alerts
  has_many :callouts, through: :alerts
  has_many :delivery_attempts

  validates :phone_number, presence: true, length: { minimum: 3 }
  validates :iso_country_code, presence: true

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
