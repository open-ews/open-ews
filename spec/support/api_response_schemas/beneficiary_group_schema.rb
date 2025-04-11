module APIResponseSchema
  BeneficiaryGroupSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "beneficiary_group")

    required(:attributes).schema do
      required(:name).filled(:str?)
    end
  end
end
