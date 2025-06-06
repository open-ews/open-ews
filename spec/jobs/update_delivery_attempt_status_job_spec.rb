require "rails_helper"

RSpec.describe UpdateDeliveryAttemptStatusJob do
  it "updates the status of a delivery attempt" do
    account = create(:account)
    broadcast = create(:broadcast, :running, account:)
    notification = create(:notification, broadcast:)
    delivery_attempt = create(
      :delivery_attempt,
      :initiated,
      notification:,
      metadata: {
        "somleng_call_sid" => "call-sid"
      }
    )
    stub_somleng_request(response: { body: { "status" => "completed", "duration" => "87" }.to_json })

    UpdateDeliveryAttemptStatusJob.perform_now(delivery_attempt)

    expect(delivery_attempt).to have_attributes(
      metadata: {
        "somleng_call_sid" => "call-sid",
        "somleng_status" => "completed",
        "call_duration" => 87
      },
      status: "succeeded",
      completed_at: be_present,
      status_update_queued_at: nil
    )
  end

  def stub_somleng_request(response:)
    stub_request(:get, %r{https://api.somleng.org}).to_return(response)
  end
end
