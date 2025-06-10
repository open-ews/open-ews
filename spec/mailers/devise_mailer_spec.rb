require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  describe "#confirmation_instructions" do
    it "handles normal domains" do
      account = create(:account, subdomain: "example")
      user = create(:user, account:)

      mail = DeviseMailer.confirmation_instructions(user, "abc")

      mail_body = Capybara.string(mail.html_part.body.raw_source)
      expect(mail_body).to have_link("Confirm my account", href: "http://example.app.lvh.me/users/confirmation?confirmation_token=abc")
    end
  end
end
