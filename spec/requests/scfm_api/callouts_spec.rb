require "rails_helper"

RSpec.resource "Callouts" do
  header("Content-Type", "application/json")

  get "/api/callouts" do
    example "List all Callouts" do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      create(:broadcast)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body.first.fetch("id")).to eq(broadcast.id)
    end
  end

  post "/api/callouts" do
    example "Create a Callout" do
      request_body = {
        audio_url: "https://www.example.com/sample.mp3",
        metadata: {
          "foo" => "bar"
        }
      }

      set_authorization_header_for(account)
      do_request(request_body)

      expect(response_status).to eq(201)
      parsed_response = JSON.parse(response_body)
      created_broadcast = account.broadcasts.find(parsed_response.fetch("id"))
      expect(created_broadcast.metadata).to eq(request_body.fetch(:metadata))
      expect(created_broadcast.audio_url).to eq(request_body.fetch(:audio_url))
      expect(parsed_response.fetch("status")).to eq("initialized")
    end
  end

  get "/api/callouts/:id" do
    example "Retrieve a Callout" do
      broadcast = create(:broadcast, account: account)

      set_authorization_header_for(account)
      do_request(id: broadcast.id)

      expect(response_status).to eq(200)
      parsed_response = JSON.parse(response_body)
      expect(
        account.broadcasts.find(parsed_response.fetch("id"))
      ).to eq(broadcast)
    end
  end

  post "/api/callouts/:callout_id/callout_events" do
    example "Create a Callout Event" do
      broadcast = create(
        :broadcast,
        :running,
        account: account
      )

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id, event: "stop")

      expect(response_status).to eq(201)
      expect(response_headers["Location"]).to eq(api_callout_path(broadcast))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("stopped")
      expect(broadcast.reload.status).to eq("stopped")
    end

    example "Create a callout event with an invalid state transition", document: false do
      broadcast = create(
        :broadcast,
        :running,
        account: account
      )

      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id, event: "start")

      expect(response_status).to eq(201)
      expect(response_headers["Location"]).to eq(api_callout_path(broadcast))
      parsed_body = JSON.parse(response_body)
      expect(parsed_body.fetch("status")).to eq("running")
      expect(broadcast.reload.status).to eq("running")
    end
  end

  let(:account) { create(:account) }
end
