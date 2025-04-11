require "rails_helper"

module V1
  RSpec.describe JSONAPIRequestSchema, type: :request_schema do
    it "validates the resource id" do
      resource = create(:beneficiary)

      schema = Class.new(JSONAPIRequestSchema) do
        params do
          required(:data).value(:hash).schema do
            required(:type).filled(:str?, eql?: "beneficiary")
            required(:id).filled(:int?)
          end
        end
      end

      expect(
        schema.new(input_params: { data: { type: "beneficiary", id: resource.id } }, options: { resource: })
      ).to have_valid_field(:data, :id)

      expect(
        schema.new(input_params: { data: { type: "beneficiary" } }, options: { resource: })
      ).not_to have_valid_field(:data, :id)

      expect(
        schema.new(input_params: { data: { type: "beneficiary", id: resource.id + 1 } }, options: { resource: })
      ).not_to have_valid_field(:data, :id)
    end
  end
end
