require "rails_helper"

RSpec.describe "Home", type: :system do
  it "renders the dashboard" do
    account = create(:account)
    user = create(:user, account:)
    completed_broadcast = create(:broadcast, :completed, account:)
    running_broadcast = create(:broadcast, :running, account:)

    create_list(:notification, 10, broadcast: completed_broadcast, status: :succeeded)
    create_list(:notification, 2, broadcast: running_broadcast, status: :succeeded)
    create_list(:notification, 3, broadcast: running_broadcast, status: :pending)

    autovacuum_analyze
    account_sign_in(user)
    visit dashboard_root_path

    expect(page).to have_title("Dashboard")
    expect(page).to have_content("Total Broadcasts")
    expect(page).to have_content("Total Notifications Sent")
    expect(page).to have_content("Total Beneficiaries")
    expect(page).to have_content("Notifications sent in the last 12 months")

    within ".beneficiary-stats .total-count" do
      expect(page).to have_content("15")
    end

    within ".notifications-stats .total-count" do
      expect(page).to have_content("12")
    end

    within ".broadcasts-stats .total-count" do
      expect(page).to have_content("2")
    end

    within ".broadcast-card-#{completed_broadcast.id}" do
      expect(page).to have_content("Succeeded 100%")
      expect(page).to have_content("Pending 0%")
      expect(page).to have_content("Failed 0%")
    end

    within ".broadcast-card-#{running_broadcast.id}" do
      expect(page).to have_content("Succeeded 40%")
      expect(page).to have_content("Pending 60%")
      expect(page).to have_content("Failed 0%")
    end
  end
end
