require "rails_helper"

module V1
  RSpec.describe BroadcastRequestSchema, type: :request_schema do
    it "validates the beneficiary filter" do
      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {},
              relationships: {
                beneficiary_groups: {}
              }
            }
          }
        )
      ).to have_valid_field(:data, :attributes, :beneficiary_filter)

      expect(
        validate_schema(
          input_params: {
            data: { attributes: {} }
          }
        )
      ).not_to have_valid_field(:data, :attributes, :beneficiary_filter)
    end

    it "validates the beneficiary groups" do
      account = create(:account)
      other_beneficiary_group = create(:beneficiary_group)

      expect(
        validate_schema(
          input_params: {
            data: {
              relationships: {
                beneficiary_groups: {
                  data: [
                    {
                      id: other_beneficiary_group.id,
                      type: "beneficiary_group"
                    }
                  ]
                }
              }
            }
          },
          options: {
            account:,
          }
        )
      ).not_to have_valid_field(:data, :relationships, :beneficiary_groups, :data)
    end

    it "validates the status" do
      account = create(:account)

      expect(
        validate_schema(
          input_params: {
            data: {
              attributes: {
                channel: "voice",
                status: "running"
              }
            }
          },
          options: {
            account:,
          }
        )
      ).not_to have_valid_schema(error_message: "Account not configured")
    end

    def validate_schema(input_params:, options: {})
      BroadcastRequestSchema.new(
        input_params:,
        options: options.reverse_merge(account: build_stubbed(:account))
      )
    end
  end
end
