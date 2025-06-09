require "rails_helper"

RSpec.describe ForgotSubdomainMailer, type: :mailer do
  describe "#forgot_subdomain" do
    it "handles multiple domains" do
      account = create(:account, name: "NCDM")
      user = create(:user, account:, name: "Bob Chann")

      mail = ForgotSubdomainMailer.forgot_subdomain(user)

      mail_body = Capybara.string(mail.html_part.body.raw_source)
      expect(mail_body).to have_content("Bob Chann")
      expect(mail_body).to have_link(dashboard_root_url(host: account.subdomain_host), href: dashboard_root_url(host: account.subdomain_host))
    end
  end
end
