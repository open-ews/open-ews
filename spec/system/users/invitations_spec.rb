 require "rails_helper"

RSpec.describe "Invitations" do
  it "accepts an invitation" do
    account = create(:account, :with_logo, name: "My Alerting Authority")
    perform_enqueued_jobs do
      User.invite!(
        account:,
        email: "johndoe@example.com",
        name: "John Doe"
      )
    end

    open_email("johndoe@example.com")
    visit_full_link_in_email("Accept invitation")

    expect(page).to have_image(alt: "My Alerting Authority Logo")
    fill_in("Password", with: "password123")
    fill_in("Password confirmation", with: "password123")
    click_on("Set my password")

    expect(page).to have_text("Your password was set successfully. You are now signed in.")
  end
end
