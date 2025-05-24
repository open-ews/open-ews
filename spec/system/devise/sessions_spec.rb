require "rails_helper"

RSpec.describe "User sign in" do
  it "can sign in" do
    user = create(:user, password: "mysecret")

    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: "mysecret"
    click_on "Log in"

    expect(page).to have_text("Signed in successfully.")
  end

  it "can sign out" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    within(".user-dropdown") do
      click_on "Sign out"
    end

    expect(page).to have_content("You need to sign in or sign up before continuing")
  end
end
