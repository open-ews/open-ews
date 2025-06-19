require "rails_helper"

RSpec.describe ExportCSV do
  describe "#call" do
    context "when exporting with filter params" do
      it "exports only records matching the filter criteria" do
        user = create(:user)
        account = user.account

        _pending_broadcast = create(:broadcast, :pending, account: account)
        _running_broadcast = create(:broadcast, :running, account: account)
        completed_broadcast = create(
          :broadcast,
          :completed,
          audio_url: "https://example.com/audio.mp3",
          beneficiary_filter: { gender: { eq: "F" } },
          account: account
        )

        completed_broadcast.beneficiary_groups << create(:beneficiary_group, name: "Group 1", account: account)
        completed_broadcast.beneficiary_groups << create(:beneficiary_group, name: "Group 2", account: account)

        export = create(
          :export,
          resource_type: "Broadcast",
          filter_params: { status: { eq: "completed" } },
          user: user,
          account: account
        )

        ExportCSV.call(export)

        expect(export.reload).to be_completed
        expect(export.progress_percentage).to eq(100)
        expect(export.file).to be_attached

        csv_content = export.file.download
        csv_data = CSV.parse(csv_content, headers: true)

        expect(csv_data.length).to eq(1)
        exported_broadcast = csv_data.first
        expect(exported_broadcast["id"]).to eq(completed_broadcast.id.to_s)
        expect(exported_broadcast["status"]).to eq("completed")
        expect(exported_broadcast["channel"]).to eq("voice")
        expect(exported_broadcast["audio_url"]).to eq("https://example.com/audio.mp3")
        expect(JSON.parse(exported_broadcast["beneficiary_filter"])).to eq({ "gender" => { "eq" => "F" } })
        expect(exported_broadcast["error_code"]).to be_nil
        expect(exported_broadcast["beneficiary_groups"]).to eq('["Group 1","Group 2"]')
      end
    end

    context "when exporting without filter params" do
      it "exports all records" do
        user = create(:user)
        account = user.account

        create(:broadcast, :pending, account: account)
        create(:broadcast, :completed, account: account)
        create(:broadcast, :running, account: account)

        export = create(
          :export,
          resource_type: "Broadcast",
          filter_params: {},
          user: user,
          account: account
        )

        ExportCSV.call(export)

        csv_content = export.file.download
        csv_data = CSV.parse(csv_content, headers: true)

        expect(csv_data.length).to eq(3)
      end
    end
  end
end
