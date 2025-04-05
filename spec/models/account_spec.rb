require "rails_helper"

RSpec.describe Account do
  let(:factory) { :account }

  include_examples "has_metadata"

  it "sets the defaults" do
    account = Account.new

    account.save!

    expect(account.settings).to eq(
      {
        "from_phone_number" => "1234",
        "phone_call_queue_limit" => 200,
        "max_phone_calls_for_callout_participation" => 3
      }
    )
  end
end
