require "rails_helper"

RSpec.describe UpdateBroadcast do
  it "updates the broadcast" do
    broadcast = create(:broadcast, :pending)

    UpdateBroadcast.call(broadcast, desired_status: :queued)

    expect(broadcast).to have_attributes(status: "queued")
    expect(broadcast.account.events).to include(
      have_attributes(
        type: "broadcast.updated",
        details: hash_including(
          "data" => hash_including(
            "id" => broadcast.id.to_s,
            "type" => "broadcast"
          )
        )
      )
    )
  end

  it "sets started by" do
    broadcast = create(:broadcast, :pending)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :queued, updated_by: user)

    expect(broadcast).to have_attributes(status: "queued", started_by: user, updated_by: user)
  end

  it "sets stopped by" do
    broadcast = create(:broadcast, :running)
    user = create(:user, account: broadcast.account)

    UpdateBroadcast.call(broadcast, desired_status: :stopped, updated_by: user)

    expect(broadcast).to have_attributes(status: "stopped", stopped_by: user, updated_by: user)
  end

  it "raises an error when the desired status is invalid" do
    broadcast = create(:broadcast, :pending)

    expect { UpdateBroadcast.call(broadcast, desired_status: :stopped) }.to raise_error(UpdateBroadcast::InvalidStateTransitionError)
  end
end
