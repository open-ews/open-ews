class InitiateDeliveryAttemptJob < ApplicationJob
  class Handler
    class AudioNotAttachedError < StandardError; end

    include Rails.application.routes.url_helpers

    attr_reader :delivery_attempt, :somleng_client, :twiml_builder

    def initialize(delivery_attempt, **options)
      @delivery_attempt = delivery_attempt
      @somleng_client = options.fetch(:somleng_client) do
        Somleng::Client.new(
          account_sid: delivery_attempt.account.somleng_account_sid,
          auth_token: delivery_attempt.account.somleng_auth_token
        )
      end
      @twiml_builder = options.fetch(:twiml_builder) { TwiMLBuilder.new }
    end

    def perform
      return if delivery_attempt.initiated?
      raise(AudioNotAttachedError, "Audio file not attached") unless delivery_attempt.broadcast.audio_file.attached?

      delivery_attempt.transaction do
        response = initiate_call
        delivery_attempt.transition_to!(:initiated)
        update_metadata!(
          somleng_call_sid: response.sid
        )
        delivery_attempt.save!
      end
    rescue Somleng::Client::RestError => e
      delivery_attempt.transaction do
        HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")
        update_metadata!(
          somleng_error_message: e.message,
          alert_phone_number:
        )
      end
    end

    private

    def initiate_call
      somleng_client.create_call(
        to: delivery_attempt.phone_number,
        from: alert_phone_number,
        twiml: build_twiml,
        status_callback: somleng_webhooks_delivery_attempt_call_status_callbacks_url(delivery_attempt, protocol: :https, subdomain: :api),
      )
    end

    def build_twiml
      twiml_builder.play(audio_url).to_xml
    end

    def audio_url
      AudioURL.new(key: delivery_attempt.broadcast.audio_file.key).url
    end

    def alert_phone_number
      delivery_attempt.account.alert_phone_number
    end

    def update_metadata!(metadata)
      metadata.each do |key, value|
        delivery_attempt.metadata[key.to_s] = value
      end
      delivery_attempt.save!
    end
  end

  discard_on Handler::AudioNotAttachedError

  def perform(...)
    Handler.new(...).perform
  end
end
