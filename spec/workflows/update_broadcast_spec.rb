require "rails_helper"

RSpec.describe UpdateBroadcast do
  it "updates the broadcast" do
    broadcast = create(:broadcast, :pending)

    UpdateBroadcast.call(broadcast, desired_status: :queued)

    expect(broadcast).to have_attributes(status: "queued")
  end

  it "raises an error when the desired status is invalid" do
    broadcast = create(:broadcast, :pending)

    expect { UpdateBroadcast.call(broadcast, desired_status: :stopped) }.to raise_error(UpdateBroadcast::InvalidStateTransitionError)
  end
end
