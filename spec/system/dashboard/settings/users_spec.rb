require "rails_helper"

RSpec.describe "Users" do
  it "can list all users" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    account_sign_in(user)
    visit dashboard_settings_users_path

    expect(page).to have_link(
      other_user.name,
      href: dashboard_settings_user_path(other_user)
    )
  end

  it "can show a user" do
    user = create(:user, name: "John Doe", email: "user@example.com")

    account_sign_in(user)
    visit dashboard_settings_users_path
    click_on("John Doe")

    expect(page).to have_content("John Doe")
    expect(page).to have_content("user@example.com")
  end

  it "can invite a user" do
    user = create(:user, name: "Bob Chann")

    account_sign_in(user)
    visit(dashboard_settings_users_path)
    click_on("New")

    fill_in("Email", with: "user@example.com")
    fill_in("Name", with: "John Doe")

    perform_enqueued_jobs do
      click_on "Send an invitation"
    end

    expect(page).to have_content("An invitation email has been sent to user@example.com.")
    expect(page).to have_content("user@example.com")
    expect(page).to have_content("John Doe")
    expect(page).to have_link("Bob Chann", href: dashboard_settings_user_path(user))
  end

  it "handles form validations" do
    user = create(:user)

    account_sign_in(user)
    visit(new_dashboard_settings_user_path)

    click_on "Send an invitation"

    expect(page).to have_content("Name can't be blank")
    expect(page).to have_content("Email can't be blank")
  end
end
