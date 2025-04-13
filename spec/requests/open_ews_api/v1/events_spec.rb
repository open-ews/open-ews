require "rails_helper"

RSpec.resource "Events"  do
  explanation <<~HEREDOC
    The Events API provides a structured way to track and respond to significant changes within the OpenEWS system.
    An event represents something that has occurred—such as the creation, update, or deletion of a key resource like a beneficiary or broadcast.
    Events are generated in real time as the system state changes, enabling external services to monitor and react to important activity.
    This allows for powerful integrations, audit trails, automation, and synchronization across connected systems.

    Typical use cases include:

    * Triggering notifications when new beneficiaries are registered
    * Syncing deletions or updates with third-party databases
    * Logging significant system activity for compliance or analytics

    Each event includes metadata such as the event type and timestamp.

    The Events API currently supports the following event types:

    #{Event.type.values.map { "* `#{_1}`" }.join("\n")}
  HEREDOC

  get "/v1/events" do
    with_options scope: :filter do
      FieldDefinitions::EventFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "List all events" do
      account = create(:account)
      event = create(:event, :beneficiary_created, account:)
      create(:event)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("event")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        event.id.to_s
      )
    end

    example "Filter events" do
      account = create(:account)
      event = create(:event, :beneficiary_deleted, account:)
      create(:event, :beneficiary_deleted, account:, created_at: 60.seconds.ago)
      create(:event, :beneficiary_created, account:)

      set_authorization_header_for(account)
      do_request(filter: { type: { eq: "beneficiary.deleted" }, created_at: { gt: 59.seconds.ago } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("event")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        event.id.to_s
      )
    end
  end

  get "/v1/events/:id" do
    example "Fetch an event" do
      account = create(:account)
      event = create(:event, account:)

      set_authorization_header_for(account)
      do_request(id: event.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("event")
    end
  end

  get "/v1/events/stats" do
    explanation <<~HEREDOC
      Returns aggregate statistics about events in the OpenEWS system.
      This endpoint provides insights into the volume and types of events generated over a given period.
    HEREDOC

    with_options scope: :filter do
      FieldDefinitions::EventFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    parameter(
      :group_by,
      "An array of fields to group by. Supported fields: #{V1::EventStatsRequestSchema::GROUPS.map { |group| "`#{group}`" }.join(", ")}.",
      required: true
    )

    example "Fetch event stats" do
      explanation <<~HEREDOC
        This example filters events by the type `beneficiary.deleted` and restricts the results to a specific time range. The returned data is grouped by event type
      HEREDOC

      account = create(:account)
      create(:event, account:, type: "beneficiary.created")
      create(:event, account:, type: "beneficiary.deleted", created_at: 2.days.ago)
      create(:event, account:, type: "beneficiary.deleted", created_at: 3.days.ago)
      create(:event, account:, type: "beneficiary.deleted", created_at: 5.days.ago)

      set_authorization_header_for(account)
      do_request(
        filter: { type: { eq: "beneficiary.deleted" }, created_at: { between: [4.days.ago.utc.iso8601, 1.day.ago.utc.iso8601] } },
        group_by: [
          "type"
        ]
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }

      expect(results).to contain_exactly(
        {
          "type" => "beneficiary.deleted",
          "value" => 2
        }
      )
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(400)
    end
  end
end
