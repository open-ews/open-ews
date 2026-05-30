require "rails_helper"

RSpec.describe "Alerts" do
  it "lists alerts" do
    user = create(:user, id: 1)
    account_sign_in(user)

    visit dashboard_alerts_path

    expect(page).to have_title("Alerts")
    expect(page).to have_content("Flood")
  end

  it "create a new alert" do
    user = create(:user, id: 1)
    account_sign_in(user)

    visit dashboard_alerts_path
    click_on "New"
    fill_in("Headline", with: "Flood warning for Rawalpindi")

    click_on "Create Alert"
    expect(page).to have_content("Alert created successfully.")
    expect(page).to have_content("Flood warning for Rawalpindi")
  end

  it "approve an alert" do
    user = create(:user, id: 2)
    account_sign_in(user)

    visit dashboard_alert_path(4)
    click_on "Approve"

    expect(page).to have_content("Alert updated successfully.")
    expect(page).to have_content("Approved")
  end
end
