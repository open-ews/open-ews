require "rails_helper"

RSpec.describe InitiateDeliveryAttemptJob do
  describe "#perform" do
    it "initiates a voice delivery attempt" do
      account = create(
        :account,
        notification_phone_number: "1294",
        somleng_account_sid: "account-sid",
        somleng_auth_token: "auth-token"
      )
      broadcast = create(:broadcast, :voice, :with_attached_audio, account:, audio_filename: "test.mp3")
      notification = create(:notification, broadcast:)
      delivery_attempt = create(
        :delivery_attempt,
        :queued,
        notification:,
        phone_number: "855715100999"
      )
      stub_somleng_request(
        response: {
          body: { "sid" => "call-sid", "status" => "queued" }.to_json
        }
      )

      InitiateDeliveryAttemptJob.perform_now(delivery_attempt)

      expect(WebMock).to have_requested(
        :post,
        "https://api.somleng.org/2010-04-01/Accounts/account-sid/Calls.json"
      ).with(
        body: URI.encode_www_form(
          "From" => "1294",
          "StatusCallback" => Rails.application.routes.url_helpers.somleng_webhooks_delivery_attempt_call_status_callbacks_url(delivery_attempt, subdomain: "api"),
          "To" => "855715100999",
          "Twiml" => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n<Play>https://uploads.open-ews.org/#{broadcast.audio_file.key}.mp3</Play>\n</Response>\n",
        ),
        headers: {
          "Authorization" => "Basic #{Base64.strict_encode64('account-sid:auth-token')}"
        }
      )

      expect(delivery_attempt).to have_attributes(
        status: "initiated",
        initiated_at: be_present,
        metadata: {
          "somleng_resource_sid" => "call-sid"
        }
      )
    end

    it "initiates an SMS delivery attempt" do
      account = create(
        :account,
        notification_phone_number: "1294",
        somleng_account_sid: "account-sid",
        somleng_auth_token: "auth-token"
      )
      broadcast = create(:broadcast, :sms, account:, message: "Test message")
      notification = create(:notification, broadcast:)
      delivery_attempt = create(
        :delivery_attempt,
        :queued,
        notification:,
        phone_number: "855715100999"
      )
      stub_somleng_request(
        response: {
          body: { "sid" => "message-sid", "status" => "queued" }.to_json
        }
      )

      InitiateDeliveryAttemptJob.perform_now(delivery_attempt)

      expect(WebMock).to have_requested(
        :post,
        "https://api.somleng.org/2010-04-01/Accounts/account-sid/Messages.json"
      ).with(
        body: URI.encode_www_form(
          "Body" => "Test message",
          "From" => "1294",
          "StatusCallback" => Rails.application.routes.url_helpers.somleng_webhooks_delivery_attempt_message_status_callbacks_url(delivery_attempt, subdomain: "api"),
          "To" => "855715100999"
        ),
        headers: {
          "Authorization" => "Basic #{Base64.strict_encode64('account-sid:auth-token')}"
        }
      )

      expect(delivery_attempt).to have_attributes(
        status: "initiated",
        initiated_at: be_present,
        metadata: {
          "somleng_resource_sid" => "message-sid"
        }
      )
    end

    it "handles errors" do
      account = create(:account, notification_phone_number: "1294")
      broadcast = create(:broadcast, :with_attached_audio, account:)
      notification = create(:notification, broadcast:)
      delivery_attempt = create(:delivery_attempt, :queued, notification:)
      stub_somleng_request(response: { status: 422 })

      InitiateDeliveryAttemptJob.perform_now(delivery_attempt)

      expect(delivery_attempt).to have_attributes(
        status: "failed",
        initiated_at: nil,
        completed_at: be_present,
        metadata: {
          "somleng_error_message" => be_present,
          "notification_phone_number" => "1294",
          "somleng_status" => "errored"
        }
      )
      expect(RetryNotificationJob).to have_been_enqueued.with(notification)
    end

    def stub_somleng_request(response:)
      stub_request(:post, %r{https://api.somleng.org}).to_return(response)
    end
  end
end
