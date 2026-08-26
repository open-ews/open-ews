require "rails_helper"

RSpec.describe BeneficiaryFilter, type: :request_schema do
  it "validates the filter" do
    expect(
      validate_schema(
        input_params: {
          filter: {
            gender: { eq: "M" }
          }
        }
      )
    ).to have_valid_field(:filter, :gender)

    expect(
      validate_schema(
        input_params: {
          filter: {
            gender: { eq: "B" }
          }
        }
      )
    ).not_to have_valid_field(:filter, :gender)
  end

  it "validates conjunctions" do
    expect(
      validate_schema(
        input_params: {
          filter: {
            "$or": {
              "1": { gender: { eq: "M" } },
              "2": { iso_language_code: { eq: "eng" } }
            }
          }
        }
      )
    ).to have_valid_field(:filter, :$or)

    expect(
      validate_schema(
        input_params: {
          filter: {
            "$or": {}
          }
        }
      )
    ).not_to have_valid_field(:filter, :$or)

    expect(
      validate_schema(
        input_params: {
          filter: {
            "$or": "foo"
          }
        }
      )
    ).not_to have_valid_field(:filter, :$or)

    expect(
      validate_schema(
        input_params: {
          filter: {
            "$or": {
              "1": "foo"
            }
          }
        }
      )
    ).not_to have_valid_field(:filter, :$or, "1")

    expect(
      validate_schema(
        input_params: {
          filter: {
            "$or": {
              "1": { gender: { eq: "B" } }
            }
          }
        }
      )
    ).not_to have_valid_field(:filter, :$or, "1", :gender, :eq)
  end

  it "handles postprocessing" do
    schema = validate_schema(
      input_params: {
        filter: {
          "$or": {
            "1": {
              gender: { eq: "M" },
              date_of_birth: { lt: "2020-01-01" },
              invalid_field: { eq: "invalid" }
            },
            "2": { iso_language_code: { eq: "eng" } },
            "3": { invalid_field: { eq: "invalid" } },
            "4": {
              "$and": {
                "1": {
                  iso_country_code: { eq: "US" }
                },
                "2": {
                  "address.iso_region_code": { eq: "US-AL" }
                }
              }
            }
          },
          iso_country_code: { in: [ "KH", "AU" ] },
          "address.iso_region_code": { eq: "KH-12" }
        }
      }
    )

    result = schema.output

    FilterScopeQuery.new(Beneficiary, result).apply

    expect(result).to contain_exactly(
      have_attributes(
        conditions: contain_exactly(
          have_attributes(
            conditions: contain_exactly(
              have_attributes(
                field_definition: have_attributes(
                  name: :gender
                ),
                operator: :eq,
                value: "M"
              ),
              have_attributes(
                field_definition: have_attributes(
                  name: :iso_language_code
                ),
                operator: :eq,
                value: "eng"
              )
            )
          )
        )
      ),
      have_attributes(
        field_definition: have_attributes(
          name: :iso_country_code
        ),
        operator: :in,
        value: [ "KH", "AU" ]
      ),
      have_attributes(
        field_definition: have_attributes(
          name: :iso_region_code
        ),
        operator: :eq,
        value: "KH-12"
      )
    )
  end

  def validate_schema(input_params:)
    BeneficiaryFilter.filter_contract.new(input_params:)
  end
end
