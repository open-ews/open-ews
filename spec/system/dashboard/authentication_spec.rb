require "rails_helper"

RSpec.describe "Dashboard Authentication", type: :system do
  it "allows access to the dashboard" do
    account = create(:account)
    create(:user, email: "user@example.com", password: "password123", account:)

    set_app_host(account)
    visit(new_user_session_path)
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    click_on("Log in")

    expect(page).to have_content("Signed in successfully")
    expect(page).to have_current_path(dashboard_root_path)
  end

  it "denies access for cross domain requests" do
    account = create(:account)
    create(:user, email: "user@example.com", password: "password123", account:)
    other_account = create(:account)

    set_app_host(other_account)
    visit(new_user_session_path)
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    click_on("Log in")

    expect(page).to have_content("Invalid email or password")
    expect(page).to have_current_path(new_user_session_path)
  end
end
