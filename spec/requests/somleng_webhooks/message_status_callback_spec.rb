require "rails_helper"

RSpec.describe "Message Status Callbacks" do
  it "Handles message status callbacks" do
    account = create(:account, somleng_account_sid: "account-sid", somleng_auth_token: "auth-token")
    broadcast = create(:broadcast, :running, :sms, account:)
    notification = create(:notification, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, notification:)

    request_body = build_request_body(
      account_sid: account.somleng_account_sid,
      message_status: "delivered",
      from: "1294",
      to: delivery_attempt.phone_number
    )

    perform_enqueued_jobs do
      post(
        somleng_webhooks_delivery_attempt_message_status_callbacks_url(delivery_attempt, subdomain: AppSettings.fetch(:api_subdomain)),
        params: request_body,
        headers: {
          "X-Twilio-Signature" => build_somleng_signature(
            auth_token: account.somleng_auth_token,
            url: somleng_webhooks_delivery_attempt_message_status_callbacks_url(delivery_attempt, subdomain: AppSettings.fetch(:api_subdomain)),
            params: request_body
          )
        }
      )
    end

    expect(response.code).to eq("204")
    expect(delivery_attempt.reload).to have_attributes(
      status: "succeeded",
      metadata: hash_including(
        "somleng_status" => "delivered"
      ),
      completed_at: be_present
    )
    expect(notification.reload).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
  end

  def build_request_body(**options)
    {
      MessageSid: options.fetch(:message_sid) { SecureRandom.uuid },
      From: options.fetch(:from),
      To: options.fetch(:to),
      MessageStatus: options.fetch(:message_status),
      AccountSid: options.fetch(:account_sid),
      ApiVersion: options.fetch(:api_version) { "2010-04-01" }
    }.compact
  end

  def build_somleng_signature(...)
    Somleng::RequestValidator.new.build_signature_for(...)
  end
end
