require "rails_helper"

RSpec.describe FilterScopeQuery, type: :model do
  it "handles relationships without an association" do
    beneficiary_with_address = create(:beneficiary)
    create(:beneficiary_address, beneficiary: beneficiary_with_address)
    beneficiary_without_address = create(:beneficiary)

    filter_field = FilterField.new(
      field_definition: find_field_definition("address.iso_region_code"),
      operator: "is_null",
      value: true
    )

    query = FilterScopeQuery.new(Beneficiary, Array(filter_field))

    result = query.apply

    expect(result).to contain_exactly(beneficiary_without_address)
  end

  it "returns unique results" do
    beneficiary = create(:beneficiary)
    create_list(:beneficiary_address, 2, beneficiary:, iso_region_code: "KH-1")

    filter_field = FilterField.new(
      field_definition: find_field_definition("address.iso_region_code"),
      operator: "in",
      value: [ "KH-1", "KH-2" ]
    )

    query = FilterScopeQuery.new(Beneficiary, Array(filter_field))

    result = query.apply

    expect(result).to contain_exactly(beneficiary)
  end

  def find_field_definition(name)
    FieldDefinitions::BeneficiaryFields.find(name)
  end
end
