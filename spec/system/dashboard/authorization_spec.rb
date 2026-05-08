require "rails_helper"

RSpec.describe "Dashboard Authorization" do
  it "hides settings navigation for members" do
    user = create(:user, :member, name: "Member User")

    account_sign_in(user)
    visit dashboard_root_path

    within(".topbar-nav") do
      click_on("Member User")
      expect(page).not_to have_link("Settings")
    end
  end

  it "prevents members from opening account settings URLs" do
    user = create(:user, :member)

    account_sign_in(user)

    [
      dashboard_settings_account_path,
      dashboard_settings_users_path,
      dashboard_settings_developer_path
    ].each do |path|
      visit(path)

      expect(page).to have_current_path(dashboard_root_path)
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  it "allows members to keep using non-settings CRUD" do
    user = create(:user, :member)

    account_sign_in(user)
    visit dashboard_beneficiaries_path
    click_on "New"

    fill_in("Phone number", with: "85516789000")
    select("Cambodia", from: "Country")
    click_on "Create Beneficiary"

    expect(page).to have_content("Beneficiary was successfully created.")
    expect(page).to have_content("+855 16 789 000")
  end
end
