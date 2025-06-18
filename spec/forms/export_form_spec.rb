require "rails_helper"

RSpec.describe ExportForm, type: :model do
  it "creates an export" do
    user = create(:user)

    result = ExportForm.new(
      user: user,
      resource_type: "Broadcast",
      filter_params: {
        status: {
          operator: "eq",
          value: "pending"
        }
      }
    ).save!

    export = Export.last
    expect(result).to be_truthy
    expect(export.resource_type).to eq("Broadcast")
    expect(export.filter_params).to eq({ "status" => { "eq" => "pending" } })
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExportCSV.to_s, export)
  end
end
