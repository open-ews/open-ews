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

  it "handles inputs for voice" do
    account = create(:account)

    form = BroadcastForm.new(account:, audio_file: file_fixture("test.mp3"), channel: :voice, beneficiary_filter: { gender: { operator: "eq", value: "M" } })

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

    expect(form.save).to be_truthy

    expect(form.object).to have_attributes(
      persisted?: true,
      channel: "voice",
      audio_file: be_attached,
      beneficiary_filter: {
        "gender" => { "eq" => "M" }
      }
    )
  end

  it "handles inputs for SMS" do
    account = create(:account)
    form = BroadcastForm.new(account:, message: "Test message", channel: :sms)

    expect(form).to have_attributes(
      account:,
      channel: "sms",
      message: "Test message"
    )

    expect(form.save).to be_truthy

    expect(form.object).to have_attributes(
      persisted?: true,
      channel: "sms",
      message: "Test message"
    )
  end

  it "handles updates" do
    broadcast = create(:broadcast, :voice)
    form = BroadcastForm.new(account: broadcast.account, object: broadcast, channel: "sms")

    form.save

    expect(broadcast.reload.channel).to eq("voice")
  end

  it "validates the beneficiary groups length" do
    account = create(:account)
    beneficiary_groups = create_list(:beneficiary_group, 11, account:)
    form = BroadcastForm.new(account:, beneficiary_groups: beneficiary_groups.pluck(:id))

    form.valid?

    expect(form.errors[:beneficiary_groups]).to be_present
  end
end
