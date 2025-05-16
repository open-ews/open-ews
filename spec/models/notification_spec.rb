require "rails_helper"

RSpec.describe Notification do
  it "sets defaults" do
    beneficiary = create(:beneficiary)
    notification = build(:notification, beneficiary: beneficiary)

    notification.save!

    expect(notification.phone_number).to eq(beneficiary.phone_number)
  end
end
