class UpdateDeliveryAttemptStatusJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_low_priority_queue_name)

  class Handler
    attr_reader :delivery_attempt, :somleng_client

    def initialize(delivery_attempt, **options)
      @delivery_attempt = delivery_attempt
      @somleng_client = options.fetch(:somleng_client) do
        Somleng::Client.new(
          account_sid: delivery_attempt.account.somleng_account_sid,
          auth_token: delivery_attempt.account.somleng_auth_token
        )
      end
    end

    def perform
      return unless delivery_attempt.initiated?

      somleng_resource_sid = delivery_attempt.metadata.fetch("somleng_resource_sid")

      response = if delivery_attempt.broadcast.channel.voice?
        somleng_client.fetch_call(somleng_resource_sid)
      elsif delivery_attempt.broadcast.channel.sms?
        somleng_client.fetch_message(somleng_resource_sid)
      end

      delivery_attempt.transaction do
        HandleDeliveryAttemptStatusUpdate.call(
          delivery_attempt,
          status_update: DeliveryAttemptStatusUpdate.new(
            channel: delivery_attempt.broadcast.channel,
            status: response.status
          )
        )
        delivery_attempt.metadata["call_duration"] = response.call_duration if response.call_duration.present?
        delivery_attempt.status_update_queued_at = nil
        delivery_attempt.save!
      end
    end
  end

  def perform(...)
    Handler.new(...).perform
  end
end
