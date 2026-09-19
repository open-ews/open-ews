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

  describe "#api_key" do
    it "returns the correct API key" do
      account = create(:account)
      create(:access_token, account:, scopes: :"read:broadcast")
      api_key = create(:access_token, account:, scopes: :write)

      expect(account.api_key).to eq(api_key.token)
    end
  end
end
