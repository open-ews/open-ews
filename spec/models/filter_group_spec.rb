require "rails_helper"

RSpec.describe FilterGroup, type: :model do
  describe "#to_query" do
    it "combines conditions with `and`" do
      gender_filter = FilterField.new(field_definition: find_field_definition("gender"), operator: "eq", value: "M")
      status_filter = FilterField.new(field_definition: find_field_definition("status"), operator: "eq", value: "active")

      result = FilterGroup.new(operator: :and, conditions: [ gender_filter, status_filter ]).to_query

      expect(result.to_sql).to eq(
        Beneficiary.arel_table["gender"].eq("M").and(Beneficiary.arel_table["status"].eq("active")).to_sql
      )
    end

    it "combines conditions with `or`" do
      gender_filter = FilterField.new(field_definition: find_field_definition("gender"), operator: "eq", value: "M")
      status_filter = FilterField.new(field_definition: find_field_definition("status"), operator: "eq", value: "active")

      result = FilterGroup.new(operator: :or, conditions: [ gender_filter, status_filter ]).to_query

      expect(result.to_sql).to eq(
        Beneficiary.arel_table["gender"].eq("M").or(Beneficiary.arel_table["status"].eq("active")).to_sql
      )
    end

    it "supports nested groups" do
      gender_filter = FilterField.new(field_definition: find_field_definition("gender"), operator: "eq", value: "M")
      language_filter = FilterField.new(field_definition: find_field_definition("iso_language_code"), operator: "eq", value: "en")
      status_filter = FilterField.new(field_definition: find_field_definition("status"), operator: "eq", value: "active")

      nested_or = FilterGroup.new(operator: :or, conditions: [ gender_filter, language_filter ])
      result = FilterGroup.new(operator: :and, conditions: [ nested_or, status_filter ]).to_query

      expected = Beneficiary.arel_table["gender"].eq("M")
        .or(Beneficiary.arel_table["iso_language_code"].eq("en"))
        .and(Beneficiary.arel_table["status"].eq("active"))

      expect(result.to_sql).to eq(expected.to_sql)
    end
  end

  describe "#associations" do
    it "flattens associations from its conditions, including nested groups" do
      iso_region_code_filter = FilterField.new(field_definition: find_field_definition(:iso_region_code), operator: "eq", value: "KH-1")
      gender_filter = FilterField.new(field_definition: find_field_definition("gender"), operator: "eq", value: "M")

      nested_group = FilterGroup.new(operator: :or, conditions: [ iso_region_code_filter ])
      group = FilterGroup.new(operator: :and, conditions: [ nested_group, gender_filter ])

      expect(group.associations).to eq(iso_region_code_filter.associations)
    end
  end

  def find_field_definition(name)
    FieldDefinitions::BeneficiaryFields.find_by!(name:)
  end
end
