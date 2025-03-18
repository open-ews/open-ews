module API
  module V1
    class AccountsController < BaseController
      def show
        respond_with_resource(current_account)
      end
    end
  end
end
