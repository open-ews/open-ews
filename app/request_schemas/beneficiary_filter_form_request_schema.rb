class BeneficiaryFilterFormRequestSchema < ApplicationRequestSchema
  params do
    optional(:gender).value(:hash).schema do
      field_definition = FieldDefinitions::BeneficiaryFields.find("gender")

      required(:operator).filled(:string, included_in?: field_definition.operators)
      required(:value).filled(:string)
    end

    optional(:language_code).value(:hash).schema do
      field_definition = FieldDefinitions::BeneficiaryFields.find("language_code")

      required(:operator).filled(:string, included_in?: field_definition.operators)
      required(:value).filled(:string)
    end

    optional(:disability_status).value(:hash).schema do
      field_definition = FieldDefinitions::BeneficiaryFields.find("disability_status")

      required(:operator).filled(:string, included_in?: field_definition.operators)
      required(:value).filled(:string)
    end

    optional(:date_of_birth).value(:hash).schema do
      field_definition = FieldDefinitions::BeneficiaryFields.find("date_of_birth")

      required(:operator).filled(:string, included_in?: field_definition.operators)
      required(:value).filled(:string)
    end
  end

  def output
    super.each_with_object({}) do |(field, filter), result|
      result[field] = {
        filter[:operator] => filter[:value]
      }
    end
  end
end
