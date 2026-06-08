require "rails_helper"

RSpec.describe CreateBroadcast do
  it "creates a broadcast event" do
    account = create(:account)

    broadcast = CreateBroadcast.call(
      account:,
      channel: "sms",
      message: "Test message",
      beneficiary_filter: {
        gender: {
          eq: "M"
        }
      }
    )

    expect(broadcast).to be_persisted
    expect(account.events).to include(
      have_attributes(
        type: "broadcast.created",
        details: hash_including(
          "data" => hash_including(
            "id" => broadcast.id.to_s,
            "type" => "broadcast",
            "attributes" => hash_including(
              "status" => "pending"
            )
          )
        )
      )
    )
  end
end
