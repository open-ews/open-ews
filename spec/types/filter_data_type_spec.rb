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
      fields: contain_exactly(
        have_attributes(
          name: :gender,
          human_name: "Gender",
          operator: have_attributes(
            name: :eq,
            human_name: "Equals"
          ),
          value: have_attributes(
            actual_value: "M",
            human_value: "Male"
          )
        ),
        have_attributes(
          name: :date_of_birth,
          human_name: "Date of birth",
          operator: have_attributes(
            name: :between,
            human_name: "Between"
          ),
          value: have_attributes(
            actual_value: [ Date.new(2000, 1, 1), Date.new(2025, 1, 1) ],
            human_value: [ Date.new(2000, 1, 1), Date.new(2025, 1, 1) ]
          )
        ),
        have_attributes(
          name: :iso_region_code,
          human_name: "ISO region code",
          operator: have_attributes(
            name: :in,
            human_name: "In"
          ),
          value: have_attributes(
            actual_value: [ "KH-12" ],
            human_value: [ "KH-12" ]
          )
        )
      )
    )
  end
end
