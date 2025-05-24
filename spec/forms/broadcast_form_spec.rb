require "rails_helper"

RSpec.describe BroadcastForm do
  context "when initialized with BroadcastForm::BeneficiaryFilterField" do
    it "keeps structure of values" do
      broadcast = create(:broadcast, beneficiary_filter: { gender: { eq: "M" } })
      beneficiary_filter = BroadcastForm::BeneficiaryFilter.new(
        gender: { operator: "eq", value: "M" }
      )

      form = BroadcastForm.initialize_with(broadcast, beneficiary_filter:)

      expect(form.beneficiary_filter.gender).to have_attributes(
        operator: "eq",
        value: "M"
      )
    end
  end

  context "when initialized with a hash from db" do
    it "casts structure of values" do
      broadcast = create(:broadcast, beneficiary_filter: { gender: { eq: "M" } })

      form = BroadcastForm.initialize_with(broadcast, beneficiary_filter: broadcast.beneficiary_filter)

      expect(form.beneficiary_filter.gender).to have_attributes(
        operator: "eq",
        value: "M"
      )
    end
  end
end
