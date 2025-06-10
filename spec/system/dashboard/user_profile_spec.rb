require "rails_helper"

RSpec.describe "User profile" do
  it "updates the users profile" do
    user = create(:user, name: "John Doe")

    account_sign_in(user)
    visit dashboard_root_path
    navigate_to_user_profile_settings_for(user, section: "Profile")

    fill_in("Name", with: "Bob Chann")
    click_on("Save")

    expect(page).to have_content("User was successfully updated.")
    within(".topbar-nav") do
      expect(page).to have_content("Bob Chann")
    end
  end

  it "user can update their email and password" do
    user = create(:user, name: "John Doe")

    account_sign_in(user)
    visit dashboard_root_path
    navigate_to_user_profile_settings_for(user, section: "Settings")
    fill_in("Email", with: "bobchan@example.com")
    fill_in("Current password", with: user.password)
    fill_in("Password", with: "New Password", match: :prefer_exact)
    fill_in("Password confirmation", with: "New Password")

    perform_enqueued_jobs do
      click_on("Save")
    end

    expect(page).to have_content("You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirmation link to confirm your new email address.")

    open_email("bobchan@example.com")
    visit_full_link_in_email("Confirm my account")

    expect(page).to have_content("Your email address has been successfully confirmed.")

    visit(dashboard_user_profile_path)
    navigate_to_user_profile_settings_for(user, section: "Settings")

    expect(page).to have_field("Email", with: "bobchan@example.com")
  end

  it "handles form validations" do
    user = create(:user, name: "John Doe")

    account_sign_in(user)
    visit dashboard_user_profile_path
    fill_in("Name", with: "")
    click_on("Save")

    expect(page).to have_content("Name can't be blank")
  end

  def navigate_to_user_profile_settings_for(user, section:)
    within(".topbar-nav") do
      click_on(user.name)
      click_on("Profile")
    end
    within(".frame-sidebar") do
      click_on(section)
    end
  end
end
