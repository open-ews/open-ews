require "rails_helper"

RSpec.describe Account do
  it "sets the defaults" do
    account = build(:account)

    account.save!

    expect(account.settings).to eq(
      {
        "from_phone_number" => "1234",
        "phone_call_queue_limit" => 200,
        "max_delivery_attempts_for_alert" => 3
      }
    )
  end
end
