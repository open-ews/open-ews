module Dashboard
  class AlertsController < DashboardController
    Badge = Data.define(:color, :icon)

    before_action :authorize_feature_flag
    helper_method :alert_badge

    def index
      authorize(:alert, policy_class: AlertPolicy)
      @alerts = FakeResource::Alert.all
    end

    def new
      @alert = FakeResource::Alert.first
      authorize(@alert, policy_class: AlertPolicy)
    end

    def create
      @alert = FakeResource::Alert.first
      authorize(@alert, policy_class: AlertPolicy)
      redirect_to(dashboard_alert_path(@alert.id), notice: "Alert created successfully.")
    end

    def show
      @alert = FakeResource::Alert.find(params[:id])
      authorize(@alert, policy_class: AlertPolicy)
      @broadcasts = FakeResource::Broadcast.all
    end

    def update
      @alert = FakeResource::Alert.find(params[:id])
      permitted_params = params.require(:alert).permit(:approval_status)
      @alert.approval_status = ActiveSupport::StringInquirer.new(permitted_params[:approval_status])
      @alert.reviewed_by = current_user.name
      @alert.reviewed_at = Time.current

      redirect_to(dashboard_alert_path(@alert.id), notice: "Alert updated successfully.")
    end

    private

    def authorize_feature_flag
      return if FeatureFlag.enabled_for?(current_user, :alerts)

      redirect_to(dashboard_root_path, alert: "Unauthorized access to alerts.")
    end

    def alert_badge(type)
      case type
      when "immediate", "extreme"
        Badge.new(color: "red", icon: "alert-octagon")
      when "expected", "severe"
        Badge.new(color: "orange", icon: "alert-triangle")
      when "future", "moderate"
        Badge.new(color: "yellow", icon: "alert-circle")
      when "flood"
        Badge.new(color: "blue", icon: "umbrella-2")
      when "earthquake"
        Badge.new(color: "orange", icon: "buildings")
      when "heat"
        Badge.new(color: "red", icon: "temperature-sun")
      when "sms"
        Badge.new(color: "green", icon: "message")
      when "pending", "pending_approval"
        Badge.new(color: "gray-200", icon: "clock")
      when "in_progress"
        Badge.new(color: "blue", icon: "hourglass-high")
      when "completed", "approved"
        Badge.new(color: "green", icon: "check")
      when "rejected"
        Badge.new(color: "red", icon: "alert-triangle")
      end
    end
  end
end
