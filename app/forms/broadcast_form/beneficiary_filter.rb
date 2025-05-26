class BroadcastForm::BeneficiaryFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :gender, BroadcastForm::BeneficiaryFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("gender"))
  attribute :disability_status, BroadcastForm::BeneficiaryFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("disability_status"))
  attribute :date_of_birth, BroadcastForm::BeneficiaryFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("date_of_birth"))
  attribute :iso_language_code, BroadcastForm::BeneficiaryFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("iso_language_code"))
  attribute :iso_region_code, BroadcastForm::BeneficiaryFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.iso_region_code"))
  attribute :administrative_division_level_2_code, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_2_code"))
  attribute :administrative_division_level_2_name, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_2_name"))
  attribute :administrative_division_level_3_code, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_3_code"))
  attribute :administrative_division_level_3_name, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_3_name"))
  attribute :administrative_division_level_4_code, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_4_code"))
  attribute :administrative_division_level_4_name, BroadcastForm::BeneficiaryAddressFilterFieldType.new(field_definition: FieldDefinitions::BeneficiaryFields.find("address.administrative_division_level_4_name"))

  def self.model_name
    ActiveModel::Name.new(self, nil, "BeneficiaryFilter")
  end
end
