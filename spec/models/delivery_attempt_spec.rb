require "rails_helper"

RSpec.describe DeliveryAttempt do
  let(:factory) { :delivery_attempt }

  include_examples "has_metadata"

  describe "locking" do
    it "prevents stale delivery attempts from being updated" do
      delivery_attempt1 = create(:delivery_attempt)
      delivery_attempt2 = DeliveryAttempt.find(delivery_attempt1.id)
      delivery_attempt1.touch

      expect { delivery_attempt2.touch }.to raise_error(ActiveRecord::StaleObjectError)
    end
  end
end
