require "rails_helper"

RSpec.describe BroadcastDecorator, type: :decorator do
  describe "#notification_stats" do
    it "returns a hash with counts for each status" do
      broadcast = create(:broadcast)
      create(:notification, :failed, broadcast:)
      create(:notification, :failed, broadcast:)
      create(:notification, :succeeded, broadcast:)
      create(:notification, :pending, broadcast:)

      decorator = BroadcastDecorator.new(broadcast)

      expect(decorator.notification_stats).to eq(
        failed: 2,
        succeeded: 1,
        pending: 1
      )
    end
  end

  describe "#notification_stats_percentage" do
    it "returns percentages for each status" do
      broadcast = create(:broadcast)
      create(:notification, :failed, broadcast:)
      create(:notification, :failed, broadcast:)
      create(:notification, :succeeded, broadcast:)
      create(:notification, :pending, broadcast:)

      decorator = BroadcastDecorator.new(broadcast)

      expect(decorator.notification_stats_percentage).to eq(
        failed: 50,
        succeeded: 25,
        pending: 25
      )
    end
  end

  describe "#total_notifications_count" do
    it "returns total count of notifications" do
      broadcast = create(:broadcast)
      create(:notification, :failed, broadcast:)
      create(:notification, :failed, broadcast:)
      create(:notification, :succeeded, broadcast:)
      create(:notification, :pending, broadcast:)

      decorator = BroadcastDecorator.new(broadcast)

      expect(decorator.total_notifications_count).to eq(4)
    end
  end
end
