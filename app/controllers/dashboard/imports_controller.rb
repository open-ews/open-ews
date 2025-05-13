module Dashboard
  class ImportsController < Dashboard::BaseController
    def create
      @resource = build_import
      @resource.save!
      ExecuteWorkflowJob.perform_later(ImportCSV.to_s, @resource)

      redirect_back(
        fallback_location: dashboard_imports_path,
        flash: {
          notice: "Your import is being processed. You can view its status from the #{helpers.link_to('Imports', dashboard_imports_path)} page."
        }
      )
    end

    private

    def build_import
      @resource = Import.new(permitted_params)
      @resource.user = current_user
      @resource.account = current_account
      @resource
    end

    def permitted_params
      params.require(:import).permit(:resource_type, :file)
    end

    def association_chain
      current_user.imports
    end
  end
end
