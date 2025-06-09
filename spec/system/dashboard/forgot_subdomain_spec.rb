require "rails_helper"

RSpec.describe "Forgot subdomain" do
  it "Handles forgotten subdomains" do
    account = create(:account, :with_logo, name: "My Alerting Authority", subdomain: "my-alerting-authority")
    create(:user, account:, email: "johndoe@example.com")

    visit(app_root_path)

    fill_in("Email", with: "johndoe@example.com")

    perform_enqueued_jobs do
      click_button("Send me login instructions")
    end

    expect(page).to have_content("You will receive an email with login instructions in a few minutes")

    open_email("johndoe@example.com")
    visit_full_link_in_email(dashboard_root_url(host: account.subdomain_host))

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_image(alt: "My Alerting Authority Logo")
  end
end
