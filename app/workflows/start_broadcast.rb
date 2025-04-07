class StartBroadcast < ApplicationWorkflow
  attr_reader :broadcast

  class Error < StandardError; end

  delegate :account, :beneficiary_filter, to: :broadcast, private: true

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      download_audio_file unless broadcast.audio_file.attached?

      create_alerts
      create_delivery_attempts

      broadcast.error_message = nil
      broadcast.transition_to!(:running, touch: :started_at)
    end
  rescue DownloadBroadcastAudioFile::Error, Error => e
    broadcast.mark_as_errored!(e.message)
  end

  private

  def download_audio_file
    DownloadBroadcastAudioFile.call(broadcast)
  end

  def create_alerts
    beneficiaries = beneficiaries_scope
    raise Error, "Account not configured" unless broadcast.account.configured_for_broadcasts?(channel: broadcast.channel)
    raise Error, "No beneficiaries match the filters" if beneficiaries.none?

    alerts = beneficiaries.find_each.map do |beneficiary|
      {
        broadcast_id: broadcast.id,
        beneficiary_id: beneficiary.id,
        phone_number: beneficiary.phone_number,
        delivery_attempts_count: 1,
        status: :queued
      }
    end

    Alert.upsert_all(alerts) if alerts.any?
  end

  def create_delivery_attempts
    delivery_attempts = broadcast.alerts.find_each.map do |alert|
      {
        broadcast_id: broadcast.id,
        beneficiary_id: alert.beneficiary_id,
        alert_id: alert.id,
        phone_number: alert.phone_number,
        status: :created
      }
    end

    DeliveryAttempt.upsert_all(delivery_attempts) if delivery_attempts.any?
  end

  def beneficiaries_scope
    @beneficiaries_scope ||= FilterScopeQuery.new(
      account.beneficiaries.active,
      BeneficiaryFilter.new(input_params: beneficiary_filter).output
    ).apply
  end
end
