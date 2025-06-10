module API
  module V1
    class BeneficiariesController < APIController
      def index
        apply_filters(scope.includes(include_parameter(only: [ :addresses, :groups ])), with: BeneficiaryFilter)
      end

      def show
        respond_with_resource(scope.find(params[:id]))
      end

      def create
        validate_request_schema(
          with: ::V1::BeneficiaryRequestSchema,
          serializer_options: { include: [ :addresses ] }
        ) do |permitted_params|
          CreateBeneficiary.call(account: current_account, **permitted_params)
        end
      end

      def update
        beneficiary = scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBeneficiaryRequestSchema,
          schema_options: { resource: beneficiary },
        ) do |permitted_params|
            beneficiary.update!(permitted_params)
            beneficiary
          end
      end

      def destroy
        DeleteBeneficiary.call(scope.find(params[:id]))

        head :no_content
      end

      private

      def scope
        current_account.beneficiaries
      end
    end
  end
end
