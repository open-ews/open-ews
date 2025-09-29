require "rails_helper"

RSpec.describe DashboardSummary do
  describe DashboardSummary::Stats do
    describe "#total_count" do
      it "returns the total number of items" do
        account = create(:account)
        create_list(:beneficiary, 2, account:)

        db_analyze
        stats = DashboardSummary::Stats.new(account.beneficiaries)

        expect(stats.total_count).to eq(2)
      end
    end

    describe "#new_count" do
      it "returns the number of items created in the 30 days" do
        freeze_time do
          account = create(:account)
          create_list(:beneficiary, 2, account:, created_at: 30.days.ago)
          create_list(:beneficiary, 3, account:, created_at: 31.days.ago)
          db_analyze

          stats = DashboardSummary::Stats.new(account.beneficiaries)

          expect(stats.new_count).to eq(2)
        end
      end
    end

    describe "#new_count_percentage" do
      it "returns the percentage of items created in the 30 days" do
        freeze_time do
          account = create(:account)
          create_list(:beneficiary, 2, account:, created_at: 30.days.ago)
          create_list(:beneficiary, 8, account:, created_at: 31.days.ago)
          db_analyze

          stats = DashboardSummary::Stats.new(account.beneficiaries)

          expect(stats.new_count_percentage).to eq(20)
        end
      end
    end
  end

  describe "#recent_broadcasts" do
    it "returns the recent broadcasts" do
      account = create(:account)
      _running_broadcast_1 = create(:broadcast, :running, account:)
      running_broadcast_2 = create(:broadcast, :running, account:)
      stopped_broadcast = create(:broadcast, :stopped, account:)
      completed_broadcast = create(:broadcast, :completed, account:)
      _errored_broadcast = create(:broadcast, :errored, account:)
      _queued_broadcast = create(:broadcast, :queued, account:)

      db_analyze
      stats = DashboardSummary.new(account).recent_broadcasts

      expect(stats).to eq([ completed_broadcast, stopped_broadcast, running_broadcast_2 ])
    end
  end

  describe "#last_12_months_notifications_stats" do
    it "returns the number of notifications created in the last 12 months" do
      account = create(:account)
      broadcast = create(:broadcast, account: account)
      other_broadcast = create(:broadcast)

      travel_to(Time.zone.local(2025, 1, 1)) do
        create_list(:notification, 12, :succeeded, broadcast:, created_at: 1.year.ago)
        create_list(:notification, 10, :succeeded, broadcast:, created_at: 5.months.ago)
        create_list(:notification, 8, :succeeded, broadcast:, created_at: 1.month.ago)
        create_list(:notification, 2, :succeeded, broadcast: other_broadcast, created_at: 1.month.ago)

        stats = DashboardSummary.new(account).last_12_months_notifications_stats

        expect(stats).to eq(
          {
            "2024-01" => { name: "Jan 2024", count: 12 },
            "2024-02" => { name: "Feb 2024", count: 0 },
            "2024-03" => { name: "Mar 2024", count: 0 },
            "2024-04" => { name: "Apr 2024", count: 0 },
            "2024-05" => { name: "May 2024", count: 0 },
            "2024-06" => { name: "Jun 2024", count: 0 },
            "2024-07" => { name: "Jul 2024", count: 0 },
            "2024-08" => { name: "Aug 2024", count: 10 },
            "2024-09" => { name: "Sep 2024", count: 0 },
            "2024-10" => { name: "Oct 2024", count: 0 },
            "2024-11" => { name: "Nov 2024", count: 0 },
            "2024-12" => { name: "Dec 2024", count: 8 }
          }
        )
      end
    end
  end
end
