module Dashboard
  class AlertsController < DashboardController
    Badge = Data.define(:color, :icon)

    before_action :authorize_feature_flag
    helper_method :alert_badge

    def index
      authorize(:alert)
      @alerts = FakeResource::Alert.all
    end

    def new
      @alert = FakeResource::Alert.first
      authorize(@alert)
    end

    def create
      permitted_params = params.require(:alert).permit(
        :event, :urgency, :severity, :language, :area_description, :headline, :description,
        :instruction, locations: []
      )
      @alert = FakeResource::Alert.new(permitted_params)
      authorize(@alert)
      @alert.created_by = current_user.name
      @alert.save
      respond_with(:dashboard, @alert, notice: "Alert created successfully.")
    end

    def show
      @alert = find_alert
      @broadcasts = FakeResource::Broadcast.all
    end

    def update
      @alert = find_alert
      permitted_params = params.require(:alert).permit(:approval_status)
      @alert.approval_status = ActiveSupport::StringInquirer.new(permitted_params[:approval_status])
      @alert.reviewed_by = current_user.name
      @alert.reviewed_at = Time.current

      redirect_to(dashboard_alert_path(@alert.id), notice: "Alert updated successfully.")
    end

    private

    def find_alert
      alert = FakeResource::Alert.find(params[:id])
      authorize(alert)
      alert
    end

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
