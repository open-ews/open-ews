require "rails_helper"

RSpec.describe UpdateDeliveryAttempt do
  it "sets the metadata" do
    delivery_attempt = create(:delivery_attempt)
    somleng_resource = build_somleng_resource(call_duration: 87, status: "completed", sip_response_code: "200")

    UpdateDeliveryAttempt.call(delivery_attempt, somleng_resource:)

    expect(delivery_attempt).to have_attributes(
      error_code: nil,
      metadata: hash_including(
        "sip_response_code" => "200",
        "call_duration" => 87,
        "somleng_status" => "completed"
      )
    )
  end

  it "sets the error code from the sip response code" do
    delivery_attempt = create(:delivery_attempt)
    somleng_resource = build_somleng_resource(sip_response_code: "404")

    UpdateDeliveryAttempt.call(delivery_attempt, somleng_resource:)

    expect(delivery_attempt).to have_attributes(
      error_code: "phone_number_unreachable",
      metadata: hash_including(
        "sip_response_code" => "404"
      )
    )
  end

  def build_somleng_resource(params = {})
    instance_double(
      Somleng::Resource,
      {
        sip_response_code: nil,
        call_duration: nil,
        status: "completed",
        **params
      }
    )
  end
end
