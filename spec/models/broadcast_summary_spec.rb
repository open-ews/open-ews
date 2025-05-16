require "rails_helper"

RSpec.describe BroadcastSummary do
  describe "#notifications_count" do
    it "returns the number of notifications" do
      broadcast = create(:broadcast)
      create(:notification, broadcast:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.notifications_count

      expect(result).to eq(1)
    end
  end

  describe "#notifications_still_to_be_called" do
    it "returns the number of notifications still to be called" do
      broadcast = create(:broadcast)
      create(:notification, :succeeded, broadcast:)
      create(:notification, :failed, broadcast:, delivery_attempts_count: 3)
      create(:notification, :failed, broadcast:, delivery_attempts_count: 1)
      create(:notification, :pending, broadcast:, delivery_attempts_count: 0)

      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.notifications_still_to_be_called

      expect(result).to eq(1)
    end
  end

  describe "#completed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      notification = create(:notification, broadcast:)
      create(:delivery_attempt, :succeeded, notification:)
      create(:delivery_attempt, :failed, notification:)

      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.completed_calls

      expect(result).to eq(1)
    end
  end

  describe "#failed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      notification = create(:notification, broadcast:)
      create(:delivery_attempt, :failed, notification:)
      create(:delivery_attempt, :initiated, notification:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.failed_calls

      expect(result).to eq(1)
    end
  end
end
