require "rails_helper"

RSpec.resource "Batch Operations" do
  header("Content-Type", "application/json")

  post "/api/batch_operations" do
    example "Populate a Callout" do
      broadcast = create(:broadcast, :pending, account:)
      body = build_batch_operation_request_body(
        type: "BatchOperation::CalloutPopulation",
        callout_id: broadcast.id,
        parameters: {
          "contact_filter_params" => {
            "metadata" => {
              "gender" => "f",
              "date_of_birth.date.gteq" => "2022-01-01",
              "date_of_birth.date.lt" => "2022-02-01",
              "deregistered_at.exists" => false
            }
          }
        }
      )

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id, **body)

      assert_batch_operation_created!(account:, request_body: body)
    end

    example "Create a batch operation with an invalid type", document: false do
      body = build_batch_operation_request_body(
        type: "Contact"
      )

      set_authorization_header_for(account)
      do_request(body)

      expect(response_status).to eq(422)
    end

    example "Create a batch operation with an invalid query", document: false do
      broadcast = create(:broadcast, account:)

      body = build_batch_operation_request_body(
        type: "BatchOperation::CalloutPopulation",
        callout_id: broadcast.id,
        parameters: {
          "contact_filter_params" => {
            "metadata" => {
              "date_of_birth.data.gteq" => "2022-01-01"
            }
          }
        }
      )

      set_authorization_header_for(account)
      do_request(body)

      expect(response_status).to eq(422)
    end
  end

  post "/api/batch_operations/:batch_operation_id/batch_operation_events" do
    example "Create a Batch Operation Event" do
      account = create(:account, :configured_for_broadcasts)
      broadcast = create(
        :broadcast,
        :pending,
        audio_url: "https://www.example.com/test.mp3",
        account:
      )
      create(:beneficiary, account:, metadata: { "gender" => "f" })
      callout_population = create(
        :callout_population,
        account:,
        broadcast:,
        status: :preview,
        parameters: {
          "contact_filter_params" => {
            "metadata" => {
              "gender" => "f"
            }
          }
        }
      )

      stub_request(:get, "https://www.example.com/test.mp3").to_return(status: 200, body: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      perform_enqueued_jobs do
        do_request(
          batch_operation_id: callout_population.id,
          event: "queue"
        )
      end

      expect(response_status).to eq(201)
      expect(response_headers.fetch("Location")).to eq(api_batch_operation_path(callout_population))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("queued")
      expect(callout_population.reload).to be_finished
      expect(broadcast.reload).to have_attributes(
        status: "running",
        started_at: be_present
      )
    end

    example "Queue a finished batch operation", document: false do
      batch_operation = create(
        :batch_operation,
        account:,
        status: BatchOperation::Base::STATE_FINISHED
      )

      set_authorization_header_for(account)
      do_request(
        batch_operation_id: batch_operation.id,
        event: "queue"
      )

      expect(response_status).to eq(422)
    end
  end

  let(:account) { create(:account) }

  def build_batch_operation_request_body(parameters: {}, metadata: {}, **options)
    {
      metadata: {
        "foo" => "bar"
      }.merge(metadata),
      parameters:
    }.merge(options)
  end

  def assert_batch_operation_created!(account:, request_body:)
    expect(response_status).to eq(201)
    parsed_response = JSON.parse(response_body)
    expect(parsed_response.fetch("metadata")).to eq(request_body.fetch(:metadata))
    expect(parsed_response.fetch("parameters")).to eq(request_body.fetch(:parameters))
    expect(
      account.batch_operations.find(parsed_response.fetch("id")).class
    ).to eq(request_body.fetch(:type).constantize)
  end
end
