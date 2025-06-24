module Dashboard
  class HomeController < DashboardController
    def index
      @dashboard_summary = DashboardSummary.new(current_account)
    end
  end
end
