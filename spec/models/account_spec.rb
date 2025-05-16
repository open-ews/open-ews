require "rails_helper"

RSpec.describe Account do
  it "sets the defaults" do
    account = build(:account)

    account.save!

    expect(account).to have_attributes(
      delivery_attempt_queue_limit: 200,
      max_delivery_attempts_for_notification: 3
    )
  end
end
