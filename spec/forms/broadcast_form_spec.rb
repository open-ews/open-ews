require "rails_helper"

RSpec.describe BroadcastForm do
  it "handles initialization" do
    broadcast = create(
      :broadcast,
      channel: :voice_call,
      beneficiary_filter: {
        gender: { eq: "M" },
        "address.iso_region_code": { eq: "KH-1" }
      },
    )

    form = BroadcastForm.initialize_with(broadcast)

    expect(form).to have_attributes(
      channel: "voice_call",
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

    form = BroadcastForm.new(account:, audio_file: file_fixture("test.mp3"), channel: :voice_call, beneficiary_filter: { gender: { operator: "eq", value: "M" } })

    expect(form).to have_attributes(
      account:,
      channel: "voice_call",
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
      channel: "voice_call",
      audio_file: be_attached,
      beneficiary_filter: {
        "gender" => { "eq" => "M" }
      }
    )
  end

  it "handles inputs for messages" do
    account = create(:account)
    user = create(:user, account:)
    form = BroadcastForm.new(account:, message: "Test message", channel: :text_message, created_by: user)

    expect(form).to have_attributes(
      account:,
      channel: "text_message",
      message: "Test message"
    )

    expect(form.save).to be_truthy

    expect(form.object).to have_attributes(
      persisted?: true,
      channel: "text_message",
      message: "Test message",
      created_via: "dashboard",
      created_by: user
    )
  end

  it "ensures the channel cannot be updated" do
    broadcast = create(:broadcast, :voice_call)
    form = BroadcastForm.new(account: broadcast.account, object: broadcast, channel: "text_message")

    form.save

    expect(broadcast.reload.channel).to eq("voice_call")
  end

  it "validates the beneficiary groups length" do
    account = create(:account)
    beneficiary_groups = create_list(:beneficiary_group, 11, account:)
    form = BroadcastForm.new(account:, beneficiary_groups: beneficiary_groups.pluck(:id))

    form.valid?

    expect(form.errors[:beneficiary_groups]).to be_present
  end

  it "validates the channel" do
    account = create(:account, supported_channels: [ "text_message" ])
    form = BroadcastForm.new(account:, channel: "voice_call")

    form.valid?

    expect(form.errors[:channel]).to be_present
  end

  it "validates the audio file presence for voice and audio broadcasts" do
    account = create(:account)
    voice_call_form = BroadcastForm.new(account:, channel: "voice_call")
    audio_form = BroadcastForm.new(account:, channel: "audio")

    voice_call_form.valid?
    audio_form.valid?

    expect(voice_call_form.errors[:audio_file]).to be_present
    expect(audio_form.errors[:audio_file]).to be_present
  end

  it "validates the message presence for message broadcasts" do
    account = create(:account)
    form = BroadcastForm.new(account:, channel: "text_message")

    form.valid?

    expect(form.errors[:message]).to be_present
  end
end
