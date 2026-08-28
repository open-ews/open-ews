require "rails_helper"

RSpec.describe FilterDataType do
  it "handles filter data types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :filter_data, FilterDataType.new(filter: BeneficiaryFilter)
    end

    expect(klass.new(filter_data: {}).filter_data).to have_attributes(fields: be_empty)

    filter = {
      "$and": {
        "0": { gender: { eq: "M" } },
        "1": { date_of_birth: { between: [ Date.new(2000, 1, 1), Date.new(2025, 1, 1) ] } },
      },
      phone_number: { eq: "+855715100888" },
      "$or": {
        "$and": {
          "0": { "address.iso_region_code": { in: [ "KH-12" ] } },
          "1": {
            "address.iso_region_code": { in: [ "KH-1" ] },
            "address.administrative_division_level_2_code": { eq: "0102" }
          },
          "$or": {
            "0": { "address.iso_region_code": { in: [ "KH-12" ] }, "gender": { eq: "F" } },
            "1": { "address.iso_region_code": { in: [ "KH-1" ] } }
          }
        }
      }
    }

    expect(klass.new(filter_data: filter).filter_data).to have_attributes(
      fields: contain_exactly(
        have_attributes(
          name: :gender,
          operator: :eq,
          value: "M"
        ),
        have_attributes(
          name: :date_of_birth,
          operator: :between,
          value: [
            Date.new(2000, 1, 1),
            Date.new(2025, 1, 1)
          ]
        ),
        have_attributes(
          name: :phone_number,
          operator: :eq,
          value: "+855715100888"
        ),
        have_attributes(
          operator: :or,
          conditions: contain_exactly(
            have_attributes(
              name: :iso_region_code,
              operator: :in,
              value: [ "KH-12" ]
            ),
            have_attributes(
              name: :iso_region_code,
              operator: :in,
              value: [ "KH-1" ]
            ),
            have_attributes(
              name: :administrative_division_level_2_code,
              operator: :eq,
              value: "0102"
            ),
            have_attributes(
              operator: :or,
              conditions: contain_exactly(
                have_attributes(
                  operator: :and,
                  conditions: contain_exactly(
                    have_attributes(
                      name: :iso_region_code,
                      operator: :in,
                      value: [ "KH-12" ]
                    ),
                    have_attributes(
                      name: :gender,
                      operator: :eq,
                      value: "F"
                    )
                  )
                ),
                have_attributes(
                  name: :iso_region_code,
                  operator: :in,
                  value: [ "KH-1" ]
                )
              ),
            )
          )
        )
      )
    )
  end
end
