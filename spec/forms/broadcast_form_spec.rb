require "rails_helper"

RSpec.describe BroadcastForm do
  it "handles initialization" do
    broadcast = create(:broadcast, channel: :voice, beneficiary_filter: { gender: { eq: "M" } })

    form = BroadcastForm.initialize_with(broadcast)

    expect(form).to have_attributes(
      channel: "voice",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        )
      )
    )
  end

  it "handles form inputs" do
    account = create(:account, iso_country_code: "KH")

    form = BroadcastForm.new(account:, channel: :voice, beneficiary_filter: { gender: { operator: "eq", value: "M" } })

    expect(form).to have_attributes(
      account:,
      channel: "voice",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        ),
        iso_country_code: have_attributes(
          operator: "eq",
          value: "KH"
        )
      )
    )
  end
end
