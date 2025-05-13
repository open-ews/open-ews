class BeneficiarySerializer < ResourceSerializer
  attributes :phone_number, :gender, :status, :disability_status, :iso_language_code, :date_of_birth, :iso_country_code, :metadata
  has_many :addresses, serializer: BeneficiaryAddressSerializer
  has_many :groups, serializer: BeneficiaryGroupSerializer
end
