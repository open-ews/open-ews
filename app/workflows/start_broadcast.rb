class StartBroadcast < ApplicationWorkflow
  attr_reader :broadcast

  class Error < Errors::ApplicationError; end

  delegate :account, to: :broadcast, private: true

  def initialize(broadcast)
    super()
    @broadcast = broadcast
  end

  def call
    ApplicationRecord.transaction do
      download_audio_file unless broadcast.audio_file.attached?
      prepare_audio_file

      create_notifications
      create_delivery_attempts

      broadcast.error_code = nil
      broadcast.transition_to!(:running, touch: :started_at)
    end
  rescue DownloadBroadcastAudioFile::Error, Error => e
    broadcast.mark_as_errored!(e.code)
  end

  private

  def download_audio_file
    DownloadBroadcastAudioFile.call(broadcast)
  end

  def prepare_audio_file
    CopyBlobWithExtension.call(blob, bucket: broadcast.audio_file.blob.service.bucket.name) if storage_service?(:amazon)
  end

  def storage_service?(service_name)
    raise(ArgumentError, "Unknown storage service name: #{service_name}") unless Rails.application.config.active_storage.service_configurations.key?(service_name.to_s)
    broadcast.audio_file.blob.service.name.to_sym == service_name.to_sym
  end

  def create_notifications
    raise(Error.new(code: :account_not_configured_for_channel)) unless broadcast.account.configured_for_broadcasts?
    notifications = []

    group_beneficiaries.find_each do |beneficiary|
      notifications << build_notification(beneficiary, priority: 0)
    end

    filtered_beneficiaries.find_each do |beneficiary|
      notifications << build_notification(beneficiary, priority: 1)
    end

    raise(Error.new(code: :no_matching_beneficiaries)) if notifications.none?

    Notification.upsert_all(notifications)
  end

  def create_delivery_attempts
    delivery_attempts = broadcast.notifications.find_each.map do |notification|
      {
        broadcast_id: broadcast.id,
        beneficiary_id: notification.beneficiary_id,
        notification_id: notification.id,
        phone_number: notification.phone_number,
        status: :created
      }
    end

    DeliveryAttempt.upsert_all(delivery_attempts)
  end

  def filtered_beneficiaries
    return Beneficiary.none if !beneficiary_filter.success? || beneficiary_filter.output.blank?

    FilterScopeQuery.new(
      account.beneficiaries.active,
      beneficiary_filter.output
    ).apply.where.not(id: group_beneficiaries.select(:id))
  end

  def beneficiary_filter
    @beneficiary_filter ||= BeneficiaryFilter.new(input_params: broadcast.beneficiary_filter)
  end

  def group_beneficiaries
    broadcast.group_beneficiaries.active
  end

  def build_notification(beneficiary, **params)
    {
      broadcast_id: broadcast.id,
      beneficiary_id: beneficiary.id,
      phone_number: beneficiary.phone_number,
      delivery_attempts_count: 1,
      status: :pending,
      **params
    }
  end
end
