require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings" do
    account = create(:account)
    user = create(:user, account:, name: "John Doe")
    somleng_account_sid = generate(:somleng_account_sid)
    somleng_auth_token = generate(:auth_token)

    account_sign_in(user)
    visit(dashboard_root_path)

    within(".topbar-nav") do
      click_on("John Doe")
      click_on("Settings")
    end

    fill_in("Name", with: "Test Account")
    select("Cambodia", from: "Country")
    fill_in("Somleng account sid", with: somleng_account_sid)
    fill_in("Somleng auth token", with: somleng_auth_token)
    attach_file("Logo", file_fixture("image.jpg"))

    click_on("Save")

    expect(page).to have_text("Account was successfully updated.")
    expect(page).to have_field("Name", with: "Test Account")
    expect(page).to have_select("Country", selected: "Cambodia")
    expect(page).to have_image(alt: "Test Account Logo")
    expect(page).to have_field("Somleng account sid", with: somleng_account_sid)
    expect(page).to have_field("Somleng auth token", with: somleng_auth_token)
  end

  it "handles validations" do
    other_account = create(:account, somleng_account_sid: generate(:somleng_account_sid))
    user = create(:user)

    account_sign_in(user)
    visit(dashboard_settings_account_path)
    fill_in("Somleng account sid", with: other_account.somleng_account_sid)
    click_on("Save")

    expect(page).to have_content("has already been taken")
  end
end
