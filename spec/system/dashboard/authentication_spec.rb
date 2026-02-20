require "rails_helper"

RSpec.describe "Dashboard Authentication", type: :system do
  it "sign in with valid OTP" do
    account = create(:account)
    user = create(:user, email: "user@example.com", password: "password123", account:, otp_required_for_login: true)

    set_app_host(account)
    visit(new_user_session_path)
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Log in")

    expect(page).to have_content("Signed in successfully")
    expect(page).to have_current_path(dashboard_root_path)
  end

  it "Sign in without OTP" do
    account = create(:account)
    user = create(:user, account:, password: "Super Secret", otp_required_for_login: false)

    set_app_host(account)
    visit(new_user_session_path)
    fill_in("Email", with: user.email)
    fill_in("Password", with: "Super Secret")
    click_on("Log in")

    fill_in("OTP Code", with: user.current_otp)
    click_on("Verify & Enable 2FA")

    expect(page).to have_content("2FA was successfully enabled")
    expect(user.reload).to have_attributes(
      otp_required_for_login: true
    )
  end

  it "denies access without a valid OTP code" do
    account = create(:account)
    create(:user, email: "user@example.com", password: "password123", account:)

    set_app_host(account)
    visit(new_user_session_path)
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    fill_in("OTP Code", with: "0")
    click_on("Log in")

    expect(page).to have_content("Invalid email or password.")
  end

  it "denies access for cross domain requests" do
    account = create(:account)
    user = create(:user, email: "user@example.com", password: "password123", account:)
    other_account = create(:account)

    set_app_host(other_account)
    visit(new_user_session_path)
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    fill_in("OTP Code", with: user.current_otp)
    click_on("Log in")

    expect(page).to have_content("Invalid email or password")
    expect(page).to have_current_path(new_user_session_path)
  end

  it "sign out" do
    user = create(:user)

    account_sign_in(user)
    visit dashboard_root_path

    within(".topbar-nav") do
      click_on "Sign out"
    end

    expect(page).to have_content("You need to sign in or sign up before continuing")
  end
end
