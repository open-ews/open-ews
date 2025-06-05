require "rails_helper"

RSpec.describe "User profile" do
  it "updates the users profile" do
    user = create(:user, name: "John Doe")

    sign_in(user)
    visit dashboard_root_path
    within(".topbar-nav") do
      click_on("John Doe")
      click_on("Profile")
    end
    within(".frame-sidebar") do
      click_on("Profile")
    end

    fill_in("Name", with: "Bob Chann")
    click_on("Save")

    expect(page).to have_content("User was successfully updated.")
    within(".topbar-nav") do
      expect(page).to have_content("Bob Chann")
    end
  end

  it "update the users password" do
    user = create(:user, name: "John Doe")

    sign_in(user)
    visit dashboard_root_path
    within(".topbar-nav") do
      click_on("John Doe")
      click_on("Profile")
    end
    within(".frame-sidebar") do
      click_on("Settings")
    end
    fill_in("Email", with: "bobchan@example.com")
    fill_in "Current password", with: user.password
    fill_in "Password", with: "New Password", match: :prefer_exact
    fill_in "Password confirmation", with: "New Password"
    click_on "Save"

    expect(page).to have_content("Your account has been updated successfully.")
    expect(page).to have_field("Email", with: "bobchan@example.com")
  end

  it "handles form validations" do
    user = create(:user, name: "John Doe")

    sign_in(user)
    visit dashboard_user_profile_path
    fill_in("Name", with: "")
    click_on("Save")

    expect(page).to have_content("Name can't be blank")
  end
end
