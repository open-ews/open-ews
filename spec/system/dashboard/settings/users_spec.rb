require "rails_helper"

RSpec.describe "Users" do
  it "can list all users" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit dashboard_settings_users_path

    expect(page).to have_title("Settings")
    expect(page).to have_link(
      other_user.name,
      href: dashboard_settings_user_path(other_user)
    )
  end

  it "can show a user" do
    user = create(:user, name: "John Doe", email: "user@example.com")

    sign_in(user)
    visit dashboard_settings_users_path
    click_on("John Doe")

    expect(page).to have_content("John Doe")
    expect(page).to have_content("user@example.com")
  end
end
