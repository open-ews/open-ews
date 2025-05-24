require "rails_helper"

RSpec.describe "Users" do
  it "can list all users" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit dashboard_settings_users_path

    expect(page).to have_title("Settings")

    expect(page).to have_link(
      other_user.id.to_s,
      href: dashboard_settings_user_path(other_user)
    )
    expect(other_user.email).to appear_before(user.email)
  end

  it "can show a user" do
    user = create(:user)

    sign_in(user)
    visit dashboard_settings_user_path(user)

    expect(page).to have_title("User ##{user.id}")
    expect(page).to have_content(user.id)
  end

  xit "can update a user" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit edit_dashboard_user_path(other_user)

    expect(page).to have_title("Edit User")

    fill_in_key_value_for(:metadata, with: { key: "name", value: "Bob Chann" })
    click_on("Save")

    expect(page).to have_text("User was successfully updated.")
    expect(page).to have_content("Bob Chann")
  end

  xit "can delete a user" do
    user = create(:user)
    other_user = create(:user, account: user.account)

    sign_in(user)
    visit dashboard_user_path(other_user)

    within("#page_actions") do
      click_on "Delete"
    end

    expect(page).to have_text("User was successfully destroyed.")
  end
end
