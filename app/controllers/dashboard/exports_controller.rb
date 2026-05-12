module Dashboard
  class ExportsController < DashboardController
    def index
      authorize(Export)
      @exports = paginate_resources(scope)
    end

    def create
      @export = ExportForm.new(user: current_user, **permitted_params)
      authorize(@export)
      @export.save!

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
