require "rails_helper"

RSpec.describe BroadcastForm do
  it "handles beneficiary filters" do
    broadcast = create(:broadcast, beneficiary_filter: { gender: { eq: "M" } })

    form = BroadcastForm.initialize_with(broadcast)

    expect(form.beneficiary_filter.gender).to have_attributes(
      operator: "eq",
      value: "M"
    )
  end
end
