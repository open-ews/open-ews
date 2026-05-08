module Dashboard
  class HomeController < DashboardController
    def index
      authorize(nil, policy_class: DashboardPolicy)
      @dashboard_summary = DashboardSummary.new(current_account)
    end
  end
end
