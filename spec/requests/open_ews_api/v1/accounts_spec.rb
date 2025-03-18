require "rails_helper"

RSpec.resource "Accounts"  do
  get "/v1/account" do
    example "Fetch account settings" do
      explanation <<~HEREDOC
        This endpoint can be used to return account settings for the authorized account.
      HEREDOC

      account = create(:account)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("account")
      expect(jsonapi_response_attributes).to include(
        "somleng_account_sid" => account.somleng_account_sid,
        "somleng_auth_token" => account.somleng_auth_token
      )
    end
  end
end
