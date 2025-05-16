module V1
  class NotificationStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [
      "status",
      *BeneficiaryStatsRequestSchema::GROUPS.map { |f| "beneficiary.#{f}" }
    ].freeze

    params do
      optional(:filter).schema(NotificationFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: NotificationFilter)

    def output
      result = super

      if result[:filter]
        result[:filter_fields] = NotificationFilter.new(input_params: result[:filter]).output
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        FieldDefinitions::NotificationFields.find(group)
      end

      result
    end
  end
end
