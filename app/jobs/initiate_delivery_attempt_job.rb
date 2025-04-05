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
        delivery_attempt.metadata["somleng_call_sid"] = response.sid
        delivery_attempt.save!
      end
    rescue Somleng::Client::RestError => e
      delivery_attempt.transition_to!(:errored)
      delivery_attempt.metadata["somleng_error_message"] = e.message
      delivery_attempt.save!
    end

    private

    def initiate_call
      somleng_client.create_call(
        to: delivery_attempt.phone_number,
        from: delivery_attempt.account.from_phone_number,
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
  end

  discard_on Handler::AudioNotAttachedError

  def perform(...)
    Handler.new(...).perform
  end
end
