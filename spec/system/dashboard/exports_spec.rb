require "rails_helper"

RSpec.describe "Exports" do
  it "exports a resource type" do
    user = create(:user)
    pending_broadcast = create(
      :broadcast,
      :pending,
      account: user.account
    )
    completed_broadcast = create(
      :broadcast,
      :completed,
      account: user.account
    )

    account_sign_in(user)
    visit dashboard_broadcasts_path(
      filter: {
        status: {
          operator: "eq",
          value: "pending"
        }
      }
    )

    expect(page).to have_content_tag_for(pending_broadcast)
    expect(page).not_to have_content_tag_for(completed_broadcast)

    perform_enqueued_jobs do
      click_on "Export"
    end

    expect(page).to have_content("Your export is being processed")

    click_on "Exports"
    click_on "Download"

    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    csv = CSV.parse(page.body, headers: true)
    expect(csv.count).to eq(1)
    expect(csv.first["id"]).to eq(pending_broadcast.id.to_s)
  end

  it "list all exports" do
    user = create(:user)

    completed_export = create(:export, :completed, user:)
    processing_export = create(:export, progress_percentage: 50, user:)
    queued_export = create(:export, progress_percentage: 0, user:)
    other_user_export = create(:export, user: create(:user))

    account_sign_in(user)
    visit dashboard_exports_path

    expect(page).to have_content_tag_for(completed_export)
    expect(page).to have_content_tag_for(processing_export)
    expect(page).to have_content_tag_for(queued_export)
    expect(page).not_to have_content_tag_for(other_user_export)
  end
end
