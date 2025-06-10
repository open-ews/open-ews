 require "rails_helper"

RSpec.describe "Confirmations" do
  it "resends confirmation instructions" do
    user = create(:user, email: "user@example.com", confirmed_at: nil, password: "password123")

    set_app_host(user.account)
    visit(new_user_session_path)

    click_on "Didn't receive confirmation instructions?"
    fill_in("Email", with: "user@example.com")
    perform_enqueued_jobs do
      click_on("Resend confirmation instructions")
    end

    open_email("user@example.com")
    visit_full_link_in_email("Confirm my account")

    expect(page).to have_text("Your email address has been successfully confirmed.")

    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password123")
    click_on("Log in")

    expect(page).to have_text("Signed in successfully.")
  end
end
