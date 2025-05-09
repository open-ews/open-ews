module V1
  class AlertStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [
      "status",
      *BeneficiaryStatsRequestSchema::GROUPS.map { |f| "beneficiary.#{f}" }
    ].freeze

    params do
      optional(:filter).schema(AlertFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: AlertFilter)

    def output
      result = super

      if result[:filter]
        result[:filter_fields] = AlertFilter.new(input_params: result[:filter]).output
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        FieldDefinitions::AlertFields.find(group)
      end

      result
    end
  end
end
