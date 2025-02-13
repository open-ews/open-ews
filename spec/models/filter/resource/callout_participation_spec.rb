require "rails_helper"

RSpec.describe Filter::Resource::CalloutParticipation do
  let(:filterable_factory) { :callout_participation }
  let(:association_chain) { CalloutParticipation.all }

  describe "#resources" do
    include_examples "metadata_attribute_filter"
    include_examples "msisdn_attribute_filter"
    include_examples "timestamp_attribute_filter"
    include_examples(
      "string_attribute_filter",
      call_flow_logic: CallFlowLogic::HelloWorld.to_s
    )

    it "filters by callout_id" do
      _non_matching_callout_participation = create(:callout_participation)
      broadcast = create(:broadcast)
      callout_participation = create(:callout_participation, broadcast: broadcast)

      filter = build_filter(callout_id: broadcast.id)

      expect(filter.resources).to match_array([ callout_participation ])
    end

    it "filters by beneficiary_id" do
      _non_matching_callout_participation = create(:callout_participation)
      beneficiary = create(:beneficiary)
      callout_participation = create(:callout_participation, beneficiary: beneficiary)

      filter = build_filter(beneficiary_id: beneficiary.id)

      expect(filter.resources).to match_array([ callout_participation ])
    end

    it "filters by callout_population_id" do
      _non_matching_callout_participation = create(:callout_participation)
      callout_population = create(:callout_population)
      callout_participation = create(:callout_participation, callout_population: callout_population)

      filter = build_filter(callout_population_id: callout_population.id)

      expect(filter.resources).to match_array([ callout_participation ])
    end
  end

  def build_filter(filter_params = {})
    described_class.new(
      { association_chain: CalloutParticipation },
      filter_params
    )
  end
end
