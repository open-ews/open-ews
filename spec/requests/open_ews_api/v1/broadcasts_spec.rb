require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts" do
    with_options scope: :filter do
      FieldDefinitions::BroadcastFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "List all broadcasts" do
      account = create(:account)
      account_broadcast = create(:broadcast, account:)
      _other_account_broadcast = create(:broadcast)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_broadcast.id.to_s
      )
    end

    example "Filter a broadcast", document: false do
      account = create(:account)
      running_broadcast = create(:broadcast, account:, status: :running)
      _stopped_broadcast = create(:broadcast, account:, status: :stopped)

      set_authorization_header_for(account)
      do_request(filter: { status: { eq: "running" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        running_broadcast.id.to_s
      )
    end
  end

  get "/v1/broadcasts/:id" do
    example "Fetch a broadcast" do
      account = create(:account)
      broadcast = create(:broadcast, account:)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "id")).to eq(broadcast.id.to_s)
    end
  end

  post "/v1/broadcasts" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `broadcast`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :channel, "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}.",
        required: true
      )
      parameter(
        :audio_url, "A publicly available URL which contains the broadcast message.",
        required: true
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the broadcast. This can be useful for storing additional information about the broadcast in a structured format."
      )
    end

    with_options scope: %i[data attributes beneficiary_filter] do
      FieldDefinitions::BeneficiaryFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "Create a broadcast" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            channel: "voice",
            audio_url: "https://www.example.com/sample.mp3",
            beneficiary_filter: {
              gender: { eq: "M" },
              "address.iso_region_code" => { eq: "KH-1" }
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channel" => "voice",
        "status" => "pending",
        "audio_url" => "https://www.example.com/sample.mp3",
        "beneficiary_filter" => {
          "gender" => { "eq" => "M" },
          "address.iso_region_code" => { "eq" => "KH-1" }
        }
      )
    end

    example "Fail to create a broadcast", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            channel: "voice",
            audio_url: nil,
            beneficiary_filter: {}
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/audio_url")
      expect(json_response.dig("errors", 1, "source", "pointer")).to eq("/data/attributes/beneficiary_filter")
    end
  end

  patch "/v1/broadcasts/:id" do
    with_options scope: %i[data] do
      parameter(
        :id, "The unique identifier of the broadcast.",
        required: true
      )
      parameter(
        :type, "Must be `broadcast`",
        required: true
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :audio_url, "A publicly available URL which contains the broadcast message. Can only be updated before the broadcast starts.",
      )
      parameter(
        :status,
        "Update the status of a broadcast. Must be one of #{V1::UpdateBroadcastRequestSchema::VALID_STATES.map { "`#{_1}`" }.join(", ")}.",
        method: :_disabled
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the broadcast. This can be useful for storing additional information about the broadcast in a structured format."
      )
    end

    with_options scope: %i[data attributes beneficiary_filter] do
      FieldDefinitions::BeneficiaryFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "Update a broadcast" do
      account = create(:account, :configured_for_broadcasts)
      _male_beneficiary = create(:beneficiary, account:, gender: "M")
      female_beneficiary = create(:beneficiary, account:, gender: "F")
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/old-sample.mp3",
        beneficiary_filter: {
          gender: "M"
        }
      )

      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          id: broadcast.id,
          data: {
            id: broadcast.id,
            type: :broadcast,
            attributes: {
              status: "running",
              audio_url: "https://www.example.com/test.mp3",
              beneficiary_filter: {
                gender: { eq: "F" }
              }
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "queued",
        "audio_url" => "https://www.example.com/test.mp3",
        "beneficiary_filter" => {
          "gender" => { "eq" => "F" }
        }
      )
      expect(broadcast.reload.status).to eq("running")
      expect(broadcast.audio_file).to be_attached
      expect(broadcast.beneficiaries).to contain_exactly(female_beneficiary)
      expect(broadcast.delivery_attempts.count).to eq(1)
      expect(broadcast.delivery_attempts.first.beneficiary).to eq(female_beneficiary)
    end

    example "Fail to update a broadcast", document: false do
      account = create(:account)
      broadcast = create(
        :broadcast,
        account:,
        status: :running
      )

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            status: "pending"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0, "source", "pointer")).to eq("/data/attributes/status")
    end
  end
end
