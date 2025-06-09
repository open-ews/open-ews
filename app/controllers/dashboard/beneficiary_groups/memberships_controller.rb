module Dashboard
  module BeneficiaryGroups
    class MembershipsController < DashboardController
      def index
        @memberships = paginate_resources(scope.includes(:beneficiary))
      end

      private

      def beneficiary_group
        @beneficiary_group ||= current_account.beneficiary_groups.find(params[:beneficiary_group_id])
      end

      def scope
        beneficiary_group.memberships
      end
    end
  end
end
