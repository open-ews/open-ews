module API
  module V1
    class BeneficiaryGroupsController < BaseController
      def index
        apply_filters(scope.includes(include_parameter(only: :members)), with: BeneficiaryGroupFilter)
      end

      def show
        respond_with_resource(scope.find(params[:id]))
      end

      def create
        validate_request_schema(with: ::V1::BeneficiaryGroupRequestSchema) do |permitted_params|
          scope.create!(permitted_params)
        end
      end

      def update
        beneficiary_group = scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBeneficiaryGroupRequestSchema,
          schema_options: { resource: beneficiary_group },
        ) do |permitted_params|
            beneficiary_group.update!(permitted_params)
            beneficiary_group
          end
      end

      def destroy
        beneficiary_group = scope.find(params[:id]).destroy!
        beneficiary_group.destroy!

        head :no_content
      end

      private

      def scope
        current_account.beneficiary_groups
      end
    end
  end
end
