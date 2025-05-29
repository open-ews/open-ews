require "rails_helper"

RSpec.describe BroadcastForm do
  it "handles initialization" do
    broadcast = create(
      :broadcast,
      channel: :voice,
      beneficiary_filter: {
        gender: { eq: "M" },
        "address.iso_region_code": { eq: "KH-1" }
      },
    )

    form = BroadcastForm.initialize_with(broadcast)

    expect(form).to have_attributes(
      channel: "voice",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        ),
        iso_region_code: have_attributes(
          operator: "eq",
          value: "KH-1"
        )
      )
    )
  end

  it "handles form inputs" do
    account = create(:account)

    form = BroadcastForm.new(account:, channel: :voice, beneficiary_filter: { gender: { operator: "eq", value: "M" } })

    expect(form).to have_attributes(
      account:,
      channel: "voice",
      beneficiary_filter: have_attributes(
        gender: have_attributes(
          operator: "eq",
          value: "M"
        )
      )
    )
  end
end
