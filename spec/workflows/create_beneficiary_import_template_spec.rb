require "rails_helper"

RSpec.describe CreateBeneficiaryImportTemplate do
  it "creates a new import template" do
    template = Pathname(Rails.root.join("app", "assets", "files", "beneficiary_import_template.csv"))

    CreateBeneficiaryImportTemplate.call(template:)

    result = CSV.read(template, headers: true)
    expect(result).to have_attributes(
      headers: match_array(
        FieldDefinitions::BeneficiaryFields.select { |field| !field.read_only? }.map { |field| field.path.to_s.parameterize.underscore }
      ),
      size: 1
    )
    expect(result[0].to_hash).to include(
      "phone_number" => "85516200101",
      "iso_country_code" => "KH"
    )
  end
end
