module API
  module V1
    class BeneficiariesController < BaseController
      SUPPORTED_RELATIONSHIPS = [ :addresses ].freeze

      def index
        apply_filters(apply_includes(beneficiaries_scope), with: BeneficiaryFilter)
      end

      def show
        beneficiary = beneficiaries_scope.find(params[:id])
        respond_with_resource(beneficiary)
      end

      def create
        validate_request_schema(
          with: ::V1::BeneficiaryRequestSchema,
          serializer_options: { include: [ :addresses ] }
        ) do |permitted_params|
            CreateBeneficiaryWithAddress.new(
              account: current_account,
              **permitted_params
            ).call
          end
      end

      def update
        beneficiary = beneficiaries_scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBeneficiaryRequestSchema,
          schema_options: { resource: beneficiary },
        ) do |permitted_params|
            beneficiary.update!(permitted_params)
            beneficiary
          end
      end

      def destroy
        beneficiary = beneficiaries_scope.find(params[:id])
        beneficiary.destroy!

        head :no_content
      end

      private

      def apply_includes(scope)
        scope.includes(includes_params)
      end

      def includes_params
        request.query_parameters.fetch(:include, "").split(",").select { SUPPORTED_RELATIONSHIPS.include?(_1.to_sym) }
      end

      def beneficiaries_scope
        current_account.beneficiaries
      end
    end
  end
end
