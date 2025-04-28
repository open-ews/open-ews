module APIResponseSchema
  BeneficiaryGroupSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "beneficiary_group")

    required(:attributes).schema do
      required(:name).filled(:str?)
    end

    required(:relationships).schema do
      required(:members).schema do
        required(:data).value(:array)
      end
    end
  end
end
