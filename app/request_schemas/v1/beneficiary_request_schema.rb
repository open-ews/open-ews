module V1
  class BeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          required(:phone_number).filled(Types::Number)
          required(:iso_country_code).filled(Types::UpcaseString, included_in?: Beneficiary.iso_country_code.values)
          optional(:iso_language_code).maybe(:string)
          optional(:date_of_birth).maybe(:date)
          optional(:gender).maybe(Types::UpcaseString, included_in?: Beneficiary.gender.values)
          optional(:disability_status).maybe(:string, included_in?: Beneficiary.disability_status.values)
          optional(:metadata).value(:hash)

          optional(:address).filled(:hash).schema do
            required(:iso_region_code).filled(:string, max_size?: 255)
            optional(:administrative_division_level_2_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_2_name).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_3_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_3_name).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_4_code).maybe(:string, max_size?: 255)
            optional(:administrative_division_level_4_name).maybe(:string, max_size?: 255)
          end
        end

        optional(:relationships).value(:hash).schema do
          optional(:groups).value(:hash).schema do
            required(:data).array(:hash) do
              required(:type).filled(:str?, eql?: "beneficiary_group")
              required(:id).filled(:int?)
            end
          end
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    attribute_rule(:phone_number) do
     next unless account.beneficiaries.where(phone_number: value).exists?

      key.failure(text: "must be unique")
    end

    attribute_rule(:address) do
      next unless key?

      validator = BeneficiaryAddressValidator.new(value)
      next if validator.valid?

      validator.errors.each do |error|
        key([*key.path, error.key]).failure(error.message)
      end
    end

    relationship_rule(:groups).validate(:beneficiary_groups)

    def output
      result = super
      result[:group_ids] = Array(result.delete(:groups))
      result
    end
  end
end
