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
end
