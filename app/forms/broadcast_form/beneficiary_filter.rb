class BroadcastForm::BeneficiaryFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :gender, BeneficiaryFilterFieldType.new
  attribute :disability_status, BeneficiaryFilterFieldType.new
  attribute :date_of_birth, BeneficiaryFilterFieldType.new
  attribute :language_code, BeneficiaryFilterFieldType.new
  attribute :iso_country_code, BeneficiaryFilterFieldType.new
  attribute :iso_region_code, BeneficiaryFilterFieldType.new
  attribute :administrative_division_level_2_code, BeneficiaryFilterFieldType.new
  attribute :administrative_division_level_3_code, BeneficiaryFilterFieldType.new
  attribute :administrative_division_level_4_code, BeneficiaryFilterFieldType.new

  def self.model_name
    ActiveModel::Name.new(self, nil, "BeneficiaryFilter")
  end
end
