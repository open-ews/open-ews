require "rails_helper"

RSpec.describe ImportCSV do
  it "imports a CSV" do
    import = create(
      :import,
      :beneficiaries
    )

    ImportCSV.call(import)

    expect(import).to have_attributes(
      status: "succeeded"
    )
  end

  it "handles invalid CSVs" do
    import = create(
      :import,
      :beneficiaries,
      file: create(:active_storage_attachment, filename: "invalid_beneficiaries.csv")
    )

    ImportCSV.call(import)

    expect(import).to have_attributes(
      status: "failed",
      error_message: be_present
    )
  end
end
