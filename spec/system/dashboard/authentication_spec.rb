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

    expect(page).to have_content("Setup 2FA")

    fill_in("OTP Code", with: user.current_otp)
    click_on("Enable")

    expect(page).to have_content("2FA was successfully enabled")
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

    expect(page).to have_content("Invalid Email or password.")
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

    expect(page).to have_content("Invalid Email or password")
    expect(page).to have_current_path(new_user_session_path)
  end
end
