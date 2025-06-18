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
    expect(export.scoped_to).to eq({ "account_id" => user.account.id })
    expect(export.filter_params).to eq({ "status" => { "eq" => "pending" } })
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExportCSV.to_s, export)
  end

  it "creates an export for nested resource type" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    result = ExportForm.new(
      user: user,
      resource_type: "Notification",
      scoped_id: broadcast.id
    ).save!

    export = Export.last
    expect(result).to be_truthy
    expect(export.resource_type).to eq("Notification")
    expect(export.scoped_to).to eq({ "broadcast_id" => broadcast.id })
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(ExportCSV.to_s, export)
  end

  it "raises an error if the scoped id is not valid" do
    user = create(:user)

    expect {
      ExportForm.new(
        user: user,
        resource_type: "Notification",
        scoped_id: nil
      ).save!
    }.to raise_error(ExportForm::InvalidFormValues)
  end
end
