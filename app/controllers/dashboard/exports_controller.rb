module Dashboard
  class ExportsController < ApplicationController
    def create
      @export = build_export

      if @export.save
        ExecuteWorkflowJob.perform_later(ExportCSV.to_s, @export)
        flash[:notice] = "<span>Your export is being processed. You can view its status from the #{helpers.link_to('Exports', dashboard_exports_path)} page.</span>"
      else
        flash[:alert] = "Failed to create export: #{@export.errors.full_messages.to_sentence}"
      end

      redirect_back_or_to(dashboard_exports_path)
    end

    private

    def build_export
      @export = current_user.exports.build(permitted_params)
      @export.account = current_account
      @export
    end

    def permitted_params
      params.require(:export).permit(:resource_type, :filter_params)
    end
  end
end
