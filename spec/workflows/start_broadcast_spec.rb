require "rails_helper"

RSpec.describe StartBroadcast do
  it "populates alerts" do
    account = create(:account, :configured_for_broadcasts)
    _male_beneficiary = create(:beneficiary, account:, gender: "M")
    female_beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary_address, beneficiary: female_beneficiary, iso_region_code: "KH-12")
    other_female_beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary_address, beneficiary: other_female_beneficiary, iso_region_code: "KH-11")

    stub_request(:get, "https://example.com/cowbell.mp3").to_return(status: 200)

    broadcast = create(
      :broadcast,
      audio_url: "https://example.com/cowbell.mp3",
      status: :queued,
      account:,
      error_message: "existing error message",
      beneficiary_filter: {
        gender: { eq: "F" },
        "address.iso_region_code": { eq: "KH-12" }
      }
    )

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "running",
      error_message: be_blank,
      started_at: be_present,
      audio_file: be_attached
    )
    expect(broadcast.beneficiaries.count).to eq(1)
    expect(broadcast.alerts.first).to have_attributes(
      beneficiary: female_beneficiary,
      phone_number: female_beneficiary.phone_number,
      delivery_attempts_count: 1
    )
    expect(broadcast.delivery_attempts.count).to eq(1)
    expect(broadcast.delivery_attempts.first).to have_attributes(
      alert: broadcast.alerts.first,
      phone_number: female_beneficiary.phone_number,
      status: "created"
    )
  end

  it "marks errored when the audio file can't be downloaded" do
    account = create(:account, :configured_for_broadcasts)
    broadcast = create(
      :broadcast,
      account:,
      status: :queued,
      audio_url: "https://example.com/not-found.mp3",
    )

    stub_request(:get, "https://example.com/not-found.mp3").to_return(status: 404)

    StartBroadcast.call(broadcast)

    expect(broadcast.status).to eq("errored")
    expect(broadcast.error_message).to eq("Unable to download audio file")
  end

  it "marks errored when there are no beneficiaries that match the filters" do
    account = create(:account, :configured_for_broadcasts)
    _male_beneficiary = create(:beneficiary, account:, gender: "M")

    broadcast = create(
      :broadcast,
      account:,
      audio_file: file_fixture("test.mp3"),
      status: :queued,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )

    StartBroadcast.call(broadcast)

    expect(broadcast.status).to eq("errored")
    expect(broadcast.error_message).to eq("No beneficiaries match the filters")
  end

  it "marks errored when the account is not yet configured for sending broadcasts" do
    account = create(:account)

    broadcast = create(
      :broadcast,
      account:,
      audio_file: file_fixture("test.mp3"),
      status: :queued,
      beneficiary_filter: {
        gender: { eq: "F" }
      }
    )

    StartBroadcast.call(broadcast)

    expect(broadcast.status).to eq("errored")
    expect(broadcast.error_message).to eq("Account not configured")
  end
end
