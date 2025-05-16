require "rails_helper"

RSpec.describe StartBroadcast do
  it "starts a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    create(:beneficiary, account:, gender: "M")
    female_beneficiaries = create_list(:beneficiary, 3, account:, gender: "F")
    female_beneficiaries.first(2).each do |beneficiary|
      create(:beneficiary_address, beneficiary:, iso_region_code: "KH-12")
    end
    beneficiary_group = create(:beneficiary_group, account:)
    other_beneficiary_group = create(:beneficiary_group, account:)
    beneficiary_in_group = create(:beneficiary, account:, gender: "M")
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: beneficiary_in_group)
    create(:beneficiary_group_membership, beneficiary_group: other_beneficiary_group, beneficiary: beneficiary_in_group)
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: female_beneficiaries.first)

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
      },
      beneficiary_groups: [ beneficiary_group, other_beneficiary_group ]
    )

    StartBroadcast.call(broadcast)

    expect(broadcast).to have_attributes(
      status: "running",
      error_message: be_blank,
      started_at: be_present,
      audio_file: be_attached
    )
    expect(broadcast.beneficiaries).to contain_exactly(*female_beneficiaries.first(2), beneficiary_in_group)
    expect(broadcast.notifications).to contain_exactly(
      have_attributes(
        beneficiary: female_beneficiaries[0],
        priority: 0,
        phone_number: female_beneficiaries[0].phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: female_beneficiaries[0].phone_number,
            status: "created"
          )
        )
      ),
      have_attributes(
        beneficiary: beneficiary_in_group,
        priority: 0,
        phone_number: beneficiary_in_group.phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: beneficiary_in_group.phone_number,
            status: "created"
          )
        )
      ),
      have_attributes(
        beneficiary: female_beneficiaries[1],
        priority: 1,
        phone_number: female_beneficiaries[1].phone_number,
        delivery_attempts_count: 1,
        status: "pending",
        delivery_attempts: contain_exactly(
          have_attributes(
            phone_number: female_beneficiaries[1].phone_number,
            status: "created"
          )
        )
      )
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
