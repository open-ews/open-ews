require "rails_helper"

RSpec.describe InitiateDeliveryAttemptJob do
  describe "#perform" do
    it "initiates the delivery attempt" do
      account = create(
        :account,
        alert_phone_number: "1294",
        somleng_account_sid: "account-sid",
        somleng_auth_token: "auth-token"
      )
      broadcast = create(:broadcast, :with_attached_audio, account:)
      alert = create(:alert, broadcast:)
      delivery_attempt = create(
        :delivery_attempt,
        :queued,
        alert:,
        phone_number: "855715100999"
      )
      stub_somleng_request(
        response: {
          body: { "sid" => "call-sid" }.to_json
        }
      )

      InitiateDeliveryAttemptJob.perform_now(delivery_attempt)

      expect(WebMock).to have_requested(
        :post,
        "https://api.somleng.org/2010-04-01/Accounts/account-sid/Calls.json"
      ).with(
        body: URI.encode_www_form(
          "From" => "1294",
          "StatusCallback" => "https://api.open-ews.org/somleng_webhooks/delivery_attempts/#{delivery_attempt.id}/call_status_callbacks",
          "To" => "855715100999",
          "Twiml" => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Play>https://uploads.open-ews.org/#{broadcast.audio_file.key}</Play>\n</Response>\n",
        ),
        headers: {
          "Authorization" => "Basic #{Base64.strict_encode64('account-sid:auth-token')}"
        }
      )

      expect(delivery_attempt).to have_attributes(
        status: "initiated",
        initiated_at: be_present,
        metadata: {
          "somleng_call_sid" => "call-sid"
        }
      )
    end

    it "handles errors" do
      account = create(:account)
      broadcast = create(:broadcast, :with_attached_audio, account:)
      alert = create(:alert, broadcast:)
      delivery_attempt = create(:delivery_attempt, :queued, alert:)
      stub_somleng_request(response: { status: 422 })

      InitiateDeliveryAttemptJob.perform_now(delivery_attempt)

      expect(delivery_attempt).to have_attributes(
        status: "errored",
        initiated_at: nil,
        errored_at: be_present,
        metadata: {
          "somleng_error_message" => be_present
        }
      )
    end

    def stub_somleng_request(response:)
      stub_request(:post, %r{https://api.somleng.org}).to_return(response)
    end
  end
end
