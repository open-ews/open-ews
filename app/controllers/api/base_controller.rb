module API
  class BaseController < ::BaseController
    include Rails::Pagination

    protect_from_forgery with: :null_session
    before_action :verify_requested_format!
    before_action :doorkeeper_authorize!

    respond_to :json

    private

    def respond_with_resource_parts
      [ :api, resource ]
    end

    def show_location(resource)
      polymorphic_path([ :api, resource ])
    end

    def resources_path
      polymorphic_path([ :api, association_chain.model ])
    end

    def respond_with_resources
      respond_with(paginated_resources)
    end

    def paginated_resources
      if filter_params.present?
        paginate(resources)
      else
        total_count = find_resources_association_chain.size
        paginate(resources, paginate_array_options: { total_count: })
      end
    end

    # Authorization

    def current_account
      @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
    end

    def deny_access!
      head(:unauthorized)
    end

    def specified_or_current_account
      current_account.super_admin? && params[:account_id] && Account.find(params[:account_id]) || current_account
    end
  end
end
