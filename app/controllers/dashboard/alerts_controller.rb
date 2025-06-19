module Dashboard
  class AlertsController < DashboardController
    Badge = Data.define(:color, :icon)

    before_action :authorize_feature_flag
    helper_method :alert_badge

    def index
      @alerts = FakeResource::Alert.all
    end

    def new
      @alert = FakeResource::Alert.first
    end

    def create
      redirect_to(dashboard_alert_path(FakeResource::Alert.first.id), notice: "Alert created successfully.")
    end

    def show
      @alert = FakeResource::Alert.find(params[:id])
      @broadcasts = FakeResource::Broadcast.all
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
      when "air_raid"
        Badge.new(color: "red", icon: "plane")
      when "sms"
        Badge.new(color: "green", icon: "message")
      when "pending"
        Badge.new(color: "gray-200", icon: "clock")
      when "in_progress"
        Badge.new(color: "blue", icon: "hourglass-high")
      when "completed"
        Badge.new(color: "green", icon: "check")
      end
    end
  end
end
