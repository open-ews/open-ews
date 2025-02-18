require "rails_helper"

RSpec.describe StartRapidproFlow do
  it "starts the a RapidPro flow" do
    flow_id = SecureRandom.uuid
    start_flow_response = build_start_flow_response(flow_id: flow_id)
    workflow = build_workflow(
      account_settings: { "rapidpro" => { "api_token" => "api-token" } },
      broadcast_settings: { "rapidpro" => { "flow_id" => flow_id } },
      rapidpro_client: fake_rapidpro_client(status: 201, response: start_flow_response)
    )

    workflow.call

    expect(workflow.rapidpro_client).to have_received(:start_flow).with(
      flow: flow_id, urns: [ "tel:#{workflow.phone_call.phone_number}" ]
    )

    expect(
      workflow.phone_call.metadata.dig("rapidpro", "flow_started_at")
    ).to be_present

    expect(workflow.phone_call.metadata.fetch("rapidpro")).to include(
      "start_flow_response_status" => 201,
      "start_flow_response_body" => start_flow_response
    )
  end

  it "uses the default RapidPro client" do
    workflow = build_workflow(
      account_settings: { "rapidpro" => { "api_token" => "api-token" } },
      rapidpro_client: nil
    )

    api_token = workflow.rapidpro_client.api_token

    expect(api_token).to eq("api-token")
  end

  it "does not start the flow if there is no RapidPro API token set" do
    workflow = build_workflow(account_settings: { rapidpro_api_token: nil })

    workflow.call

    expect(workflow.rapidpro_client).not_to have_received(:start_flow)
  end

  it "does not start the flow if there is no RapidPro flow id set" do
    workflow = build_workflow(account_settings: { rapidpro_flow_id: nil })

    workflow.call

    expect(workflow.rapidpro_client).not_to have_received(:start_flow)
  end

  it "does not start the flow if a flow has already been started" do
    workflow = build_workflow(
      account_settings: { rapidpro_api_token: "api-token" },
      callout_settings: { rapidpro_flow_id: "flow-id" }
    )
    workflow.phone_call.update!(
      metadata: {
        "rapidpro_flow_started_at" => Time.current.utc
      }
    )

    workflow.call

    expect(workflow.rapidpro_client).not_to have_received(:start_flow)
  end

  def fake_rapidpro_client(status: 201, response: build_start_flow_response)
    response = instance_double(Faraday::Response, status: status, body: response.to_json)
    instance_double(Rapidpro::Client, start_flow: response)
  end

  def build_start_flow_response(options = {})
    options.reverse_merge(
      "id" => 307615,
      "uuid" => "65674fb7-04b8-4637-a7e0-329d8b06fd80",
      "flow" => {
        "uuid" => options.delete(:flow_id) || SecureRandom.uuid,
        "name" => "emergency_maap_pdm_voice_test"
      },
      "status" => "pending",
      "groups" => [],
      "contacts" => [
        { "uuid" => "a349c473-ed46-4b1b-a960-697a8e46fa03", "name" => nil }
      ],
      "restart_participants" => true,
      "extra" => nil,
      "created_on" => "2018-11-20T06:44:50.163497Z",
      "modified_on" => "2018-11-20T06:44:50.163608Z"
    )
  end

  def build_workflow(options = {})
    account_settings = options.delete(:account_settings) || {}
    broadcast_settings = options.delete(:broadcast_settings) || {}
    rapidpro_client = options.key?(:rapidpro_client) ? options.delete(:rapidpro_client) : fake_rapidpro_client
    account = create(:account, settings: account_settings)
    broadcast = create(:broadcast, settings: broadcast_settings, account: account)
    alert = create_alert(account: account, broadcast:)
    phone_call = create_phone_call(account: account, alert: alert)
    described_class.new(phone_call, { rapidpro_client: rapidpro_client }.compact)
  end
end
