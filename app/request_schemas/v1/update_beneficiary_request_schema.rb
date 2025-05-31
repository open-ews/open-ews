module V1
  class UpdateBeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:id).filled(:integer)
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          optional(:phone_number).filled(Types::Number)
          optional(:iso_country_code).filled(Types::UpcaseString, included_in?: Beneficiary.iso_country_code.values)
          optional(:status).maybe(:string, included_in?: Beneficiary.status.values)
          optional(:disability_status).maybe(:string, included_in?: Beneficiary.disability_status.values)
          optional(:iso_language_code).maybe(:string, size?: 3)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(:string, included_in?: Beneficiary.gender.values)
          optional(:metadata).maybe(:hash?)
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    attribute_rule(:phone_number) do
      next unless key?
      next unless account.beneficiaries.where(phone_number: value).where.not(id: resource.id).exists?

      key.failure("must be unique")
    end
  end
end
