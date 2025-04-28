require "rails_helper"

module V1
  RSpec.describe BeneficiaryGroupMemberRequestSchema, type: :request_schema do
    it "validates the beneficiary_id" do
      account = create(:account)
      beneficiary = create(:beneficiary, account:)
      other_beneficiary = create(:beneficiary)
      group = create(:beneficiary_group, account:)
      existing_member = create(:beneficiary, account:)
      create(:beneficiary_group_membership, beneficiary: existing_member, beneficiary_group: group)

      expect(
        validate_schema(
          input_params: { data: { attributes: { beneficiary_id: beneficiary.id } } },
          options: {
            account:,
            beneficiary_group: group
          }
        )
      ).to have_valid_field(:data, :attributes, :beneficiary_id)

      expect(
        validate_schema(
          input_params: { data: { attributes: { beneficiary_id: other_beneficiary.id } } },
          options: {
            account:,
            beneficiary_group: group
          }
        )
      ).not_to have_valid_field(:data, :attributes, :beneficiary_id)

      expect(
        validate_schema(
          input_params: { data: { attributes: { beneficiary_id: existing_member.id } } },
          options: {
            account:,
            beneficiary_group: group
          }
        )
      ).not_to have_valid_field(:data, :attributes, :beneficiary_id)
    end

    def validate_schema(input_params:, options: {})
      BeneficiaryGroupMemberRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
