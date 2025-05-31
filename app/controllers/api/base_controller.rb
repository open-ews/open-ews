module API
  class BaseController < ActionController::API
    include Rails::Pagination

    before_action :verify_requested_format!
    before_action :doorkeeper_authorize!

    respond_to :json

    private

    # Authorization

    def current_account
      @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
    end
  end
end
