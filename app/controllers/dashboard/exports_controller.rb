module Dashboard
  class ExportsController < DashboardController
    def index
      @exports = current_user.exports.latest_first.page(params[:page])
    end

    def create
      @export = build_export

      @export.save!
      ExecuteWorkflowJob.perform_later(ExportCSV.to_s, @export)

      flash[:notice] = "<span>Your export is being processed. You can view its status from the #{helpers.link_to('Exports', dashboard_exports_path)} page.</span>"
      redirect_back_or_to(dashboard_exports_path)
    end

    private

    def build_export
      @export = current_user.exports.build(permitted_params)
      @export.account = current_account
      @export
    end

    def permitted_params
      result = params.require(:export).permit(:resource_type, filter_params: {})

      if result.key?(:filter_params)
        result[:filter_params] = normalized_filter_params(
          result.fetch(:resource_type),
          result.fetch(:filter_params)
        )
      end

      result
    end

    def normalized_filter_params(resource_type, filter_params)
      filter_form_class = filter_form(resource_type)
      filter_form = filter_form_class.new(filter_params)
      filter_form.normalized_filter_params
    end

    def filter_form(resource_type)
      "#{resource_type}FilterForm".constantize
    end
  end
end
