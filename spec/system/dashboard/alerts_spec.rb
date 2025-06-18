require "rails_helper"

RSpec.describe "Alerts" do
  it "lists alerts" do
    user = create(:user, id: 1)
    account_sign_in(user)

    visit dashboard_alerts_path

    expect(page).to have_title("Alerts")
    expect(page).to have_content("Air raid")
  end

  it "create a new alert" do
    user = create(:user, id: 1)
    account_sign_in(user)

    visit dashboard_alerts_path
    click_on "New"

    click_on "Create Alert"
    expect(page).to have_content("Alert created successfully.")
  end
end
