class CreateEvent < ApplicationWorkflow
  attr_reader :resource, :type

  delegate :account, to: :resource

  def initialize(type:, resource:)
    super()
    @type = type
    @resource = resource
  end

  def call
    event = Event.create!(
      type:,
      account:,
      details: serializer_class.new(resource).serializable_hash
    )

    webhook_endpoints.find_each do |webhook_endpoint|
      ExecuteWorkflowJob.perform_later(NotifyWebhookEndpoint.to_s, webhook_endpoint, event)
    end

    event
  end

  private

  def webhook_endpoints
    WebhookEndpoint.enabled.for_account(account).subscribed_to(type)
  end

  def serializer_class
    resource.jsonapi_serializer_class
  end
end
