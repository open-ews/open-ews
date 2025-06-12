require "rails_helper"

RSpec.describe AccountForm do
  it "saves the form" do
    account = create(:account, subdomain: "my-account")
    form = AccountForm.new(
      object: account,
      name: "My account",
      country: "KH",
      somleng_account_sid: "",
      somleng_auth_token: "",
      notification_phone_number: "",
      subdomain: "My Account"
    )

    expect(form.save).to be(true)

    expect(account).to have_attributes(
      name: "My account",
      iso_country_code: "KH",
      somleng_account_sid: nil,
      somleng_auth_token: nil,
      notification_phone_number: nil,
      subdomain: "my-account"
    )
  end
end
