module API
  module V1
    module BeneficiaryGroups
      class MembersController < API::V1::BaseController
        def index
          apply_filters(scope, with: BeneficiaryFilter)
        end

        def show
          respond_with_resource(scope.find(params[:id]))
        end

        def create
          validate_request_schema(
            with: ::V1::BeneficiaryGroupMemberRequestSchema,
            serializer_class: BeneficiarySerializer,
            schema_options: { beneficiary_group: },
          ) do |permitted_params|
            membership = beneficiary_group.memberships.create!(permitted_params)
            membership.beneficiary
          end
        end

        def destroy
          membership = beneficiary_group.memberships.find_by!(beneficiary_id: params[:id])
          membership.destroy!

          head :no_content
        end

        private

        def scope
          beneficiary_group.members
        end

        def beneficiary_group
          current_account.beneficiary_groups.find(params[:beneficiary_group_id])
        end
      end
    end
  end
end
