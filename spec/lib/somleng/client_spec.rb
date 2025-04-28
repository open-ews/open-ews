require "rails_helper"

module Somleng
  RSpec.describe Client do
    it "can create calls" do
      client = Client.new(account_sid: "account-sid", auth_token: "auth-token")
      stub_request(:post, %r{https://api.somleng.org})

      client.create_call(
        to: "+855715100876",
        from: "1294",
        url: "https://example.com"
      )

      expect(WebMock).to have_requested(
        :post,
        "https://api.somleng.org/2010-04-01/Accounts/account-sid/Calls.json"
      ).with(
        body: URI.encode_www_form(
          "From" => "1294",
          "To" => "+855715100876",
          "Url" => "https://example.com"
        ),
        headers: { "Authorization" => "Basic #{Base64.strict_encode64('account-sid:auth-token')}" }
      )
    end
  end
end
