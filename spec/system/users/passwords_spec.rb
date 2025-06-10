require "rails_helper"

RSpec.describe "Passwords" do
  it "user can reset his password" do
    user = create(:user, email: "user@example.com")

    set_app_host(user.account)
    visit(new_user_session_path)

    click_on "Forgot your password?"

    expect(page).to have_content("Forgot your password?")

    fill_in("Email", with: "user@example.com")
    perform_enqueued_jobs do
      click_on("Send me reset password instructions")
    end

    expect(page).to have_content("You will receive an email with instructions")

    open_email("user@example.com")
    visit_full_link_in_email("Change my password")
    fill_in("New password", with: "Super Secret")
    fill_in("Confirm your new password", with: "Super Secret")
    click_on("Change my password")

    expect(page).to have_content("Your password has been changed successfully. You are now signed in.")
  end
end
