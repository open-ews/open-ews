module Dashboard
  class HomeController < DashboardController
    def index
      @dashboard_summary = DashboardSummary.new(current_account)
      authorize(@dashboard_summary, policy_class: HomePolicy)
    end
  end
end
