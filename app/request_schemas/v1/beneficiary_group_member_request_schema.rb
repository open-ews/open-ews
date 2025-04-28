module V1
  class BeneficiaryGroupMemberRequestSchema < JSONAPIRequestSchema
    option :beneficiary_group

    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary_group_member")
        required(:attributes).value(:hash).schema do
          required(:beneficiary_id).filled(:int?)
        end
      end
    end

    attribute_rule(:beneficiary_id) do
      next key.failure(text: "is invalid") unless account.beneficiaries.exists?(id: value)
      next key.failure(text: "already exists") if beneficiary_group.members.exists?(id: value)
    end
  end
end
