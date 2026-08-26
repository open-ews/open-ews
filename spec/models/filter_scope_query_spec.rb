require "rails_helper"

RSpec.describe FilterScopeQuery, type: :model do
  it "handles relationships without an association" do
    beneficiary_with_address = create(:beneficiary)
    create(:beneficiary_address, beneficiary: beneficiary_with_address)
    beneficiary_without_address = create(:beneficiary)

    filter_field = FilterField.new(
      field_definition: find_field_definition(:iso_region_code),
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
      field_definition: find_field_definition(:iso_region_code),
      operator: "in",
      value: [ "KH-1", "KH-2" ]
    )

    query = FilterScopeQuery.new(Beneficiary, Array(filter_field))

    result = query.apply

    expect(result).to contain_exactly(beneficiary)
  end

  it "combines a `FilterGroup` with plain `FilterField`s" do
    matching_beneficiary = create(:beneficiary, gender: "M", status: "active")
    _wrong_gender = create(:beneficiary, gender: "F", status: "active")
    _wrong_status = create(:beneficiary, gender: "M", status: "disabled")

    gender_or_group = FilterGroup.new(
      operator: :or,
      conditions: [
        FilterField.new(field_definition: find_field_definition(:gender), operator: "eq", value: "M"),
        FilterField.new(field_definition: find_field_definition(:gender), operator: "eq", value: "X")
      ]
    )
    status_filter = FilterField.new(field_definition: find_field_definition(:status), operator: "eq", value: "active")

    query = FilterScopeQuery.new(Beneficiary, [ gender_or_group, status_filter ])

    result = query.apply

    expect(result).to contain_exactly(matching_beneficiary)
  end

  it "joins associations referenced inside a `FilterGroup`" do
    beneficiary_with_matching_address = create(:beneficiary)
    create(:beneficiary_address, beneficiary: beneficiary_with_matching_address, iso_region_code: "KH-1")
    _beneficiary_without_matching_address = create(:beneficiary)

    region_or_group = FilterGroup.new(
      operator: :or,
      conditions: [
        FilterField.new(field_definition: find_field_definition(:iso_region_code), operator: "eq", value: "KH-1")
      ]
    )

    query = FilterScopeQuery.new(Beneficiary, Array(region_or_group))

    result = query.apply

    expect(result).to contain_exactly(beneficiary_with_matching_address)
  end

  def find_field_definition(name)
    FieldDefinitions::BeneficiaryFields.find_by!(name:)
  end
end
