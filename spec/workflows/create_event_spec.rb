require "rails_helper"

RSpec.describe CreateEvent do
  it "creates an event" do
    broadcast = create(:broadcast)
    webhook_endpoint = create_webhook_endpoint(account: broadcast.account, subscriptions: [ "broadcast.created" ])

    event = CreateEvent.call(type: "broadcast.created", resource: broadcast)

    expect(event).to have_attributes(
      account: broadcast.account,
      type: "broadcast.created",
      details: hash_including(
        "data" => hash_including(
          "id" => broadcast.id.to_s,
          "type" => "broadcast"
        )
      )
    )
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(NotifyWebhookEndpoint.to_s, webhook_endpoint, event)
  end

  it "skips disabled webhook endpoints" do
    broadcast = create(:broadcast)
    create_webhook_endpoint(account: broadcast.account, subscriptions: [ "broadcast.created" ], enabled: false)

    CreateEvent.call(type: "broadcast.created", resource: broadcast)

    expect(ExecuteWorkflowJob).not_to have_been_enqueued
  end

  it "skips unsubscribed webhook endpoints" do
    broadcast = create(:broadcast)
    create_webhook_endpoint(account: broadcast.account, subscriptions: [ "broadcast.updated" ])

    CreateEvent.call(type: "broadcast.created", resource: broadcast)

    expect(ExecuteWorkflowJob).not_to have_been_enqueued
  end

  def create_webhook_endpoint(account:, **attributes)
    create(:webhook_endpoint, oauth_application: create(:oauth_application, account:), **attributes)
  end
end
