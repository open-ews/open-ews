require "rails_helper"

RSpec.describe BroadcastSummary do
  describe "#alerts_count" do
    it "returns the number of alerts" do
      broadcast = create(:broadcast)
      create(:alert, broadcast:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.alerts_count

      expect(result).to eq(1)
    end
  end

  describe "#alerts_still_to_be_called" do
    it "returns the number of alerts still to be called" do
      account = create(
        :account,
        settings: {
          max_phone_calls_for_callout_participation: 3
        }
      )
      broadcast = create(:broadcast, account: account)
      create(:alert, broadcast:, status: :completed)
      create(:alert, broadcast:, status: :failed, delivery_attempts_count: 3)
      create(:alert, broadcast:, status: :failed, delivery_attempts_count: 1)
      create(:alert, broadcast:, status: :queued, delivery_attempts_count: 0)

      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.alerts_still_to_be_called

      expect(result).to eq(1)
    end
  end

  describe "#completed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      alert = create(:alert, broadcast:)
      create(:delivery_attempt, :succeeded, alert:)
      create(:delivery_attempt, :failed, alert:)

      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.completed_calls

      expect(result).to eq(1)
    end
  end

  describe "#failed_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      alert = create(:alert, broadcast:)
      create(:delivery_attempt, :failed, alert:)
      create(:delivery_attempt, :initiated, alert:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.failed_calls

      expect(result).to eq(1)
    end
  end

  describe "#errored_calls" do
    it "returns the number of calls" do
      broadcast = create(:broadcast)
      alert = create(:alert, broadcast:)
      delivery_attempt = create(:delivery_attempt, :errored, alert:)
      delivery_attempt = create(:delivery_attempt, :initiated, alert:)
      broadcast_summary = BroadcastSummary.new(broadcast)

      result = broadcast_summary.errored_calls

      expect(result).to eq(1)
    end
  end
end
