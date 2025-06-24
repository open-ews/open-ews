require "rails_helper"

RSpec.describe DashboardSummary do
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
            "2024-01" => { name: "Jan", count: 12 },
            "2024-02" => { name: "Feb", count: 0 },
            "2024-03" => { name: "Mar", count: 0 },
            "2024-04" => { name: "Apr", count: 0 },
            "2024-05" => { name: "May", count: 0 },
            "2024-06" => { name: "Jun", count: 0 },
            "2024-07" => { name: "Jul", count: 0 },
            "2024-08" => { name: "Aug", count: 10 },
            "2024-09" => { name: "Sep", count: 0 },
            "2024-10" => { name: "Oct", count: 0 },
            "2024-11" => { name: "Nov", count: 0 },
            "2024-12" => { name: "Dec", count: 8 }
          }
        )
      end
    end
  end
end
