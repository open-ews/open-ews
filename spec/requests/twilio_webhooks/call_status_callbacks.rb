require "rails_helper"

RSpec.describe "Call Status Callbacks" do
  it "Handles call status callbacks" do
    delivery_attempt = create(:delivery_attempt, :initiated)

    request_body = build_request_body(
      account_sid: delivery_attempt.alert.broadcast.account.twilio_account_sid,
      direction: "outbound-api",
      call_status: "completed",
      from: "1294",
      to: delivery_attempt.phone_number,
      call_duration: "87"
    )

    perform_enqueued_jobs do
      post(
        twilio_webhooks_delivery_attempt_call_status_callbacks_url(delivery_attempt),
        params: request_body,
        headers: build_twilio_signature(
          auth_token: account.twilio_auth_token,
          url: twilio_webhooks_phone_call_events_url,
          request_body: request_body
        )
      )
    end

    expect(response.code).to eq("201")
    created_event = RemotePhoneCallEvent.last!
    expect(created_event).to have_attributes(
      call_duration: 87,
      delivery_attempt: have_attributes(
        status: "completed",
        call_flow_logic: CallFlowLogic::PlayMessage.to_s,
        remote_status: request_body.fetch(:CallStatus),
        duration: 87
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

  def build_twilio_signature(auth_token:, url:, request_body:)
    {
      "X-Twilio-Signature" => Twilio::Security::RequestValidator.new(
        auth_token
      ).build_signature_for(
        url, request_body
      )
    }
  end
end
