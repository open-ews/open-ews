module V1
  class BeneficiaryRequestSchema < JSONAPIRequestSchema
    params do
      required(:data).value(:hash).schema do
        required(:type).filled(:str?, eql?: "beneficiary")
        required(:attributes).value(:hash).schema do
          required(:phone_number).filled(Types::Number)
          required(:iso_country_code).filled(Types::UpcaseString, included_in?: Beneficiary.iso_country_code.values)
          optional(:language_code).maybe(:string)
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
          optional(:group).value(:hash).schema do
            required(:data).value(:hash).schema do
              required(:type).filled(:str?, eql?: "beneficiary_group")
              required(:id).filled(:int?)
            end
          end
        end
      end
    end

    attribute_rule(:phone_number).validate(:phone_number_format)
    attribute_rule(:phone_number) do |attributes|
      next unless account.beneficiaries.where(phone_number: attributes.fetch(:phone_number)).exists?

      key([ :data, :attributes, :phone_number ]).failure(text: "must be unique")
    end

    attribute_rule(:address) do |attributes|
      next if attributes[:address].blank?

      validator = BeneficiaryAddressValidator.new(attributes[:address])
      next if validator.valid?

      validator.errors.each do |error|
        key([ :data, :attributes, :address, error.key ]).failure(text: error.message)
      end
    end

    rule(data: { relationships: { group: { data: :id } } }) do
      key_path = [ :data, :relationships, :group, :data, :id ]

      next key(key_path).failure(text: "is invalid") unless account.beneficiary_groups.exists?(id: value)
    end

    def output
      result = super
      result[:group_ids] = Array(result.delete(:group))
      result
    end
  end
end
