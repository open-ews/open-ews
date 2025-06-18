module Dashboard
  class ExportsController < DashboardController
    def index
      @exports = current_user.exports.latest_first.page(params[:page])
    end

    def create
      ExportForm.new(user: current_user, **permitted_params).save!

      flash[:notice] = "<span>Your export is being processed. You can view its status from the #{helpers.link_to('Exports', dashboard_exports_path)} page.</span>"
      redirect_back_or_to(dashboard_exports_path)
    end

    private

    def permitted_params
      params.require(:export).permit(:resource_type, :scoped_id, filter_params: {})
    end
  end
end
