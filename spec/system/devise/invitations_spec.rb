require "rails_helper"

RSpec.describe "User Invitations" do
  it "can send an invitation" do
    user = create(:user)
    sign_in(user)
    visit new_user_invitation_path

    fill_in "Email", with: "bopha@somleng.com"
    fill_in "Name", with: "Bopha"

    perform_enqueued_jobs do
      click_on "Send an invitation"
    end

    expect(page).to have_text("An invitation email has been sent to bopha@somleng.com.")
    expect(last_email_sent.from).to contain_exactly("no-reply@somleng.org")
    expect(current_path).to eq(dashboard_settings_users_path)
  end

  it "can set the password" do
    inviter = create(:user)
    user = create(:user, account: inviter.account, invited_by: inviter)
    user.invite!
    visit accept_user_invitation_path(invitation_token: user.raw_invitation_token)

    fill_in "Password", with: "mysecret"
    fill_in "Password confirmation", with: "mysecret"
    click_on "Save"

    expect(page).to have_text("Your password was set successfully. You are now signed in.")
  end
end
