require "rails_helper"

RSpec.describe Broadcast do
  it "validates the number of beneficiary groups" do
    broadcast = build(:broadcast)
    broadcast.beneficiary_groups = 11.times.map { build(:beneficiary_group, account: broadcast.account) }

    expect(broadcast.valid?).to be(false)
    expect(broadcast.errors[:beneficiary_groups]).to be_present
  end
end
