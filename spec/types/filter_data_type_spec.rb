require "rails_helper"

RSpec.describe FilterDataType do
  it "handles filter data types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :filter_data, FilterDataType.new(field_definitions: FieldDefinitions::BeneficiaryFields)
    end

    expect(klass.new(filter_data: {}).filter_data).to have_attributes(fields: be_empty)

    filter = {
      gender: { eq: "M" },
      date_of_birth: { between: [ Date.new(2000, 1, 1), Date.new(2025, 1, 1) ] },
      "address.iso_region_code": {
        in: [ "KH-12" ]
      }
    }

    expect(klass.new(filter_data: filter).filter_data).to have_attributes(
      fields: include(
        gender: have_attributes(
          name: :gender,
          operator: :eq,
          value: "M",
        ),
        date_of_birth: have_attributes(
          name: :date_of_birth,
          operator: :between,
          value: [ Date.new(2000, 1, 1), Date.new(2025, 1, 1) ]
        ),
        iso_region_code: have_attributes(
          name: :iso_region_code,
          operator: :in,
          value: [ "KH-12" ]
        )
      )
    )
  end
end
