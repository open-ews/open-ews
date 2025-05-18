require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings" do
    user = create(:user)
    somleng_account_sid = generate(:somleng_account_sid)
    somleng_auth_token = generate(:auth_token)

    sign_in(user)
    visit(dashboard_settings_account_path)

    fill_in("Name", with: "Test Account")
    select("Cambodia", from: "Country")
    fill_in("Somleng account sid", with: somleng_account_sid)
    fill_in("Somleng auth token", with: somleng_auth_token)

    click_on("Save")

    expect(page).to have_text("Account was successfully updated.")
    expect(page).to have_field("Name", with: "Test Account")
    expect(page).to have_select("Country", selected: "Cambodia")
    expect(page).to have_field("Somleng account sid", with: somleng_account_sid)
    expect(page).to have_field("Somleng auth token", with: somleng_auth_token)
  end
end
