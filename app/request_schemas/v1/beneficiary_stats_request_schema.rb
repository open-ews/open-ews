module V1
  class BeneficiaryStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [
      "gender",
      "disability_status",
      "language_code",
      "iso_country_code",
      "address.iso_region_code",
      "address.administrative_division_level_2_code",
      "address.administrative_division_level_2_name",
      "address.administrative_division_level_3_code",
      "address.administrative_division_level_3_name",
      "address.administrative_division_level_4_code",
      "address.administrative_division_level_4_name"
    ].freeze

    params do
      optional(:filter).schema(BeneficiaryFilter.schema)
      required(:group_by).value(array[:string])
    end

    rule(:group_by) do
      next key.failure("is invalid") unless value.all? { |group| group.in?(GROUPS) }

      address_groups = value.select { |group| group.start_with?("address.") }
      next if address_groups.empty?
      next key.failure("address.iso_region_code is required") unless value.include?("address.iso_region_code")

      address_attributes = address_groups.each_with_object({}) do |group, result|
        _prefix, column = group.split(".")
        result[column] = true
      end
      validator = BeneficiaryAddressValidator.new(address_attributes)
      next if validator.valid?
      key.failure("address.#{validator.errors.first.key} is required")
    end

    def output
      result = super

      result[:filter_fields] = BeneficiaryFilter.new(input_params: result[:filter]).output if result[:filter]

      result[:group_by_fields] = result[:group_by].map do |group|
        BeneficiaryField.find(group)
      end

      result
    end
  end
end
