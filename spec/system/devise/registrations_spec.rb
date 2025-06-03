require 'rails_helper'

RSpec.describe "Registrations" do
  it "can update the users password" do
    user = create(:user)

    sign_in(user)
    visit edit_user_registration_path

    within(".user-registration") do
      fill_in "Current password", with: user.password
      fill_in "Password", with: "new-password", match: :prefer_exact
      fill_in "Password confirmation", with: "new-password"
      click_on "Save"
    end

    expect(page).to have_content("Your account has been updated successfully.")
  end

  it "can update the users profile" do
    user = create(:user)

    sign_in(user)
    visit edit_user_registration_path

    within(".user-profile") do
      fill_in "Name", with: "John Doe"
      click_on "Save"
    end

    expect(page).to have_content("Your account has been updated successfully.")
  end
end
