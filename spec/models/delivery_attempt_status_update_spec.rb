require "rails_helper"

RSpec.describe DeliveryAttemptStatusUpdate do
  it "returns the desired status" do
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "queued").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "ringing").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "in-progress").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "completed").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "failed").desired_status).to eq("failed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "voice_call", status: "no-answer").desired_status).to eq("failed")

    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "queued").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "accepted").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "scheduled").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "sending").desired_status).to be_nil
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "delivered").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "sent").desired_status).to eq("completed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "failed").desired_status).to eq("failed")
    expect(DeliveryAttemptStatusUpdate.new(channel: "message", status: "canceled").desired_status).to eq("failed")
  end
end
