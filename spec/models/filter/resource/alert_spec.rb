require "rails_helper"

RSpec.describe Filter::Resource::Alert do
  let(:filterable_factory) { :alert }
  let(:association_chain) { Alert.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"

    it "filters by callout_id" do
      _non_matching_callout_participation = create(:alert)
      broadcast = create(:broadcast)
      alert = create(:alert, broadcast: broadcast)

      filter = build_filter(callout_id: broadcast.id)

      expect(filter.resources).to match_array([ alert ])
    end

    it "filters by beneficiary_id" do
      _non_matching_callout_participation = create(:alert)
      beneficiary = create(:beneficiary)
      alert = create(:alert, beneficiary: beneficiary)

      filter = build_filter(beneficiary_id: beneficiary.id)

      expect(filter.resources).to match_array([ alert ])
    end
  end

  def build_filter(filter_params = {})
    described_class.new(
      { association_chain: Alert },
      filter_params
    )
  end
end
