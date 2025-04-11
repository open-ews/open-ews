module V1
  class UpdateBeneficiaryGroupRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary_group")
        required(:id).filled(:integer)
        required(:attributes).value(:hash).schema do
          required(:name).filled(:str?, max_size?: 255)
        end
      end
    end
  end
end
