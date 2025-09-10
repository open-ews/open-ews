require "rails_helper"

RSpec.describe DeliveryAttemptStatusUpdate do
  it "returns the desired status" do
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "queued").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "ringing").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "in-progress").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "completed").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "failed").desired_status).to eq("failed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice", status: "no-answer").desired_status).to eq("failed")

    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "queued").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "accepted").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "scheduled").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "sending").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "delivered").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "sent").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "failed").desired_status).to eq("failed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "sms", status: "canceled").desired_status).to eq("failed")
  end
end
