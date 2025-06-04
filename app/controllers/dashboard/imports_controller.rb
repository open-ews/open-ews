module Dashboard
  class ImportsController < DashboardController
    def index
      @imports = paginate_resources(scope)
    end

    def create
      @import = build_import
      if @import.save
        ExecuteWorkflowJob.perform_later(ImportCSV.to_s, @import)
        flash[:notice] = "Your import is being processed. You can view its status from the #{helpers.link_to('Imports', dashboard_imports_path)} page."
      else
        flash[:alert] = "Failed to create import: #{@import.errors.full_messages.to_sentence}"
      end

      redirect_back_or_to(dashboard_imports_path)
    end

    private

    def build_import
      @import = scope.new(permitted_params)
      @import.account = current_account
      @import
    end

    def permitted_params
      params.require(:import).permit(:resource_type, :file)
    end

    def scope
      current_user.imports
    end
  end
end
