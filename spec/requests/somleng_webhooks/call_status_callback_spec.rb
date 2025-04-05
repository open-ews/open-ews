require "rails_helper"

RSpec.describe "Call Status Callbacks" do
  it "Handles call status callbacks" do
    account = create(:account, somleng_account_sid: "account-sid", somleng_auth_token: "auth-token")
    broadcast = create(:broadcast, account:)
    alert = create(:alert, :queued, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, alert:)

    request_body = build_request_body(
      account_sid: account.somleng_account_sid,
      direction: "outbound-api",
      call_status: "completed",
      from: "1294",
      to: delivery_attempt.phone_number,
      call_duration: "87"
    )

    perform_enqueued_jobs do
      post(
        somleng_webhooks_delivery_attempt_call_status_callbacks_url(delivery_attempt, protocol: :https, subdomain: :api),
        params: request_body,
        headers: {
          "X-Twilio-Signature" => build_somleng_signature(
            auth_token: account.somleng_auth_token,
            url: somleng_webhooks_delivery_attempt_call_status_callbacks_url(delivery_attempt, protocol: :https, subdomain: :api),
            params: request_body
          )
        }
      )
    end

    expect(response.code).to eq("204")
    expect(delivery_attempt).to have_attributes(
      status: "succeeded",
      metadata: hash_including(
        "call_duration" => 87,
        "somleng_status" => "completed"
      )
    )
  end

  it "Handles incorrect signatures" do
    account = create(:account, :with_twilio_provider)
    request_body = build_request_body(account_sid: account.twilio_account_sid)

    post(
      twilio_webhooks_phone_call_events_url,
      params: request_body,
      headers: {
        "X-Twilio-Signature" => "wrong"
      }
    )

    expect(response.code).to eq("403")
  end

  def build_request_body(options)
    {
      CallSid: options.fetch(:call_sid) { SecureRandom.uuid },
      From: options.fetch(:from) { "+85510202101" },
      To: options.fetch(:to) { "1294" },
      Direction: options.fetch(:direction) { "inbound" },
      CallStatus: options.fetch(:call_status) { "ringing" },
      AccountSid: options.fetch(:account_sid),
      CallDuration: options.fetch(:call_duration) { nil },
      ApiVersion: options.fetch(:api_version) { "2010-04-01" }
    }.compact
  end

  def build_somleng_signature(...)
    Somleng::RequestValidator.new.build_signature_for(...)
  end
end
