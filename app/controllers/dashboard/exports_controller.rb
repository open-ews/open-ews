module Dashboard
  class ExportsController < DashboardController
    def index
      @exports = paginate_resources(scope)
    end

    def create
      ExportForm.new(user: current_user, **permitted_params).save!

      flash[:notice] = t("flash.dashboard.exports.create.notice_html", exports_path: helpers.link_to("Exports", dashboard_exports_path))
      redirect_back_or_to(dashboard_exports_path)
    end

    private

    def permitted_params
      params.require(:export).permit(:resource_type, :scoped_id, filter_params: {})
    end

    def scope
      current_user.exports
    end
  end
end
