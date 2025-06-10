require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts" do
    FieldDefinitions::BroadcastFields.each do |field|
      with_options scope: [ :filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
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

    example "Filter broadcasts" do
      account = create(:account)
      broadcast = create(:broadcast, :running, account:)
      create(:broadcast, :running, account:, started_at: 6.hours.ago, created_at: 6.hours.ago)
      create(:broadcast, :stopped, account:)

      set_authorization_header_for(account)
      do_request(filter: { status: { eq: "running" }, started_at: { gt: 5.hours.ago.utc.iso8601 } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("broadcast")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        broadcast.id.to_s
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
        required: true,
        method: :_disabled
      )
      parameter(
        :audio_url, "A publicly available URL which contains the broadcast message.",
        required: true,
        method: :_disabled
      )
      parameter(
        :status,
        "If supplied, must be `running`. This will create the broadcast and start it immediately.",
        method: :_disabled
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the broadcast. This can be useful for storing additional information about the broadcast in a structured format.",
        method: :_disabled
      )
    end

    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :data, :attributes, :beneficiary_filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    with_options scope: [ :data, :relationships, :beneficiary_groups ] do
      parameter(
        :"data.*.type", "Must be `beneficiary_group`",
        required: false,
        method: :_disabled
      )
      parameter(
        :"data.*.id", "The unique ID of the beneficiary group",
        required: false,
        method: :_disabled
      )
    end

    example "Create and start a broadcast" do
      account = create(:account, :configured_for_broadcasts)
      create(:beneficiary_address, beneficiary: create(:beneficiary, gender: "M", account:), iso_region_code: "KH-1")
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channel: "voice",
              audio_url: "https://www.example.com/test.mp3",
              status: :running,
              beneficiary_filter: {
                gender: { eq: "M" },
                "address.iso_region_code" => { in: [ "KH-1", "KH-2" ] }
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "channel" => "voice",
        "status" => "queued",
        "audio_url" => "https://www.example.com/test.mp3",
        "beneficiary_filter" => {
          "gender" => { "eq" => "M" },
          "address.iso_region_code" => { "in" => [ "KH-1", "KH-2" ] }
        }
      )
    end

    example "Create broadcast with a beneficiary group" do
      explanation <<~HEREDOC
        When creating a broadcast, you can target one or more beneficiary groups **in addition to** *or* **instead of** using a beneficiary filter.
        Beneficiaries included through groups will receive notifications with higher priority than those matched solely by the filter.
        This is especially useful when you need to ensure that specific groups, such as response teams, receive notifications regardless of filter criteria.
      HEREDOC

      account = create(:account)
      beneficiary_group = create(:beneficiary_group, account:)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :broadcast,
          attributes: {
            channel: "voice",
            audio_url: "https://www.example.com/test.mp3",
          },
          relationships: {
            beneficiary_groups: {
              data: [
                { type: "beneficiary_group", id: beneficiary_group.id }
              ]
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
    end

    example "Create broadcast for specific beneficiaries" do
      explanation <<~HEREDOC
        You can create a broadcast for a specific set of beneficiaries using the phone number filter. This is especially useful when you want to quickly send a message to a known group—such as staff, partners, or a predefined list—without needing to assign them to a beneficiary group.
        It's also helpful for **testing** broadcasts in a live environment without affecting the full beneficiary population. The priority remains the same as standard broadcasts, ensuring consistent behavior while giving you more control over delivery.
      HEREDOC

      account = create(:account, :configured_for_broadcasts)
      beneficiaries = create_list(:beneficiary, 2, account:)
      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          data: {
            type: :broadcast,
            attributes: {
              channel: "voice",
              audio_url: "https://www.example.com/test.mp3",
              status: :running,
              beneficiary_filter: {
                phone_number: { in: beneficiaries.pluck(:phone_number) }
              }
            }
          }
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
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
        "Update the status of a broadcast. Must be one of #{V1::UpdateBroadcastRequestSchema::VALID_STATES.map { "`#{it}`" }.join(", ")}.",
        method: :_disabled
      )
      parameter(
        :metadata, "Set of key-value pairs that you can attach to the broadcast. This can be useful for storing additional information about the broadcast in a structured format."
      )
    end

    with_options scope: [:data, :relationships, :beneficiary_groups] do
      parameter(
        :"data.*.type", "Must be `beneficiary_group`",
        required: false,
        method: :_disabled
      )
      parameter(
        :"data.*.id", "The unique ID of the beneficiary group",
        required: false,
        method: :_disabled
      )
    end

    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :data, :attributes, :beneficiary_filter, field.path.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "Start a broadcast" do
      account = create(:account, :configured_for_broadcasts)
      beneficiary = create(:beneficiary, account:, gender: "F")
      create(:beneficiary, account:, gender: "M")
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/test.mp3",
        beneficiary_filter: {
          gender: {
            eq: "F"
          }
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
              status: "running"
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(broadcast.reload.status).to eq("running")
      expect(broadcast.audio_file).to be_attached
      expect(broadcast.beneficiaries).to contain_exactly(beneficiary)
      expect(broadcast.delivery_attempts.count).to eq(1)
      expect(broadcast.delivery_attempts.first.beneficiary).to eq(beneficiary)
    end

    example "Stop a broadcast" do
      account = create(:account)
      broadcast = create(
        :broadcast,
        :running,
        :with_attached_audio,
        account:
      )

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            status: "stopped"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data", "attributes")).to include(
        "status" => "stopped"
      )
    end

    example "Fail to start a broadcast", document: false do
      account = create(:account, :configured_for_broadcasts)
      broadcast = create(
        :broadcast,
        :with_attached_audio,
        status: :pending,
        account:,
      )

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          id: broadcast.id,
          data: {
            id: broadcast.id,
            type: :broadcast,
            attributes: {
              status: "running"
            }
          }
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(broadcast.reload).to have_attributes(
        status: "errored",
        error_code: "no_matching_beneficiaries"
      )
    end

    example "Update a broadcast" do
      account = create(:account)
      beneficiary_group = create(:beneficiary_group, account:)
      broadcast = create(
        :broadcast,
        status: :pending,
        account:,
        audio_url: "https://www.example.com/old.mp3",
        beneficiary_filter: {
          gender: {
            eq: "M"
          }
        }
      )
      create(:broadcast_beneficiary_group, beneficiary_group:, broadcast:)

      set_authorization_header_for(account)
      do_request(
        id: broadcast.id,
        data: {
          id: broadcast.id,
          type: :broadcast,
          attributes: {
            audio_url: "https://www.example.com/new.mp3",
            beneficiary_filter: {
              gender: { eq: "F" }
            }
          },
          relationships: {
            beneficiary_groups: {
              data: [
                { type: "beneficiary_group", id: beneficiary_group.id }
              ]
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("broadcast")
      expect(json_response.dig("data")).to include(
        "attributes" => include(
          "status" => "pending",
          "audio_url" => "https://www.example.com/new.mp3",
          "beneficiary_filter" => {
            "gender" => { "eq" => "F" }
          }
        ),
        "relationships" => {
          "beneficiary_groups" => {
            "data" => [
              { "type" => "beneficiary_group", "id" => beneficiary_group.id.to_s }
            ]
          }
        }
      )
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

  get "/v1/broadcasts/:broadcast_id/audio_file" do
    example "Download a broadcast's audio file" do
      account = create(:account)
      broadcast = create(:broadcast, :with_attached_audio, audio_filename: "test.mp3", account:)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".mp3")
    end

    example "Handle when broadcast's audio file is not available", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:, audio_file: nil)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(406)
    end
  end
end
