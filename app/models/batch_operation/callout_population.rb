module BatchOperation
  class CalloutPopulation < Base
    include CustomRoutesHelper["batch_operations"]

    class Error < Errors::ApplicationError; end

    belongs_to :broadcast

    store_accessor :parameters,
                   :contact_filter_params,
                   :remote_request_params

    hash_store_reader :remote_request_params
    hash_store_reader :contact_filter_params

    accepts_nested_key_value_fields_for :contact_filter_metadata

    validates :contact_filter_params, contact_filter_params: true

    def run!
      ApplicationRecord.transaction do
        download_audio_file unless broadcast.audio_file.attached?

        create_notifications
        create_delivery_attempts

        broadcast.error_code = nil
        broadcast.transition_to!(:running, touch: :started_at)
      end
    rescue DownloadBroadcastAudioFile::Error, Error => e
      broadcast.mark_as_errored!(e.code)
    end

    def contact_filter_metadata
      contact_filter_params.with_indifferent_access[:metadata] || {}
    end

    def contact_filter_metadata=(attributes)
      return if attributes.blank?

      self.contact_filter_params = { "metadata" => attributes }
    end

    # NOTE: This is for backward compatibility until we moved to the new API
    def as_json(*)
      result = super
      result["callout_id"] = result.delete("broadcast_id")
      result
    end

    private

    def download_audio_file
      DownloadBroadcastAudioFile.call(broadcast)
    end

    def beneficiaries_scope
      Filter::Resource::Beneficiary.new(
        { association_chain: account.beneficiaries },
        contact_filter_params.with_indifferent_access
      ).resources.where.not(id: Notification.select(:beneficiary_id).where(broadcast:))
    end

    def create_notifications
      beneficiaries = beneficiaries_scope
      raise(Error.new(code: :account_not_configured_for_channel)) unless broadcast.account.configured_for_broadcasts?
      raise(Error.new(code: :no_matching_beneficiaries)) if beneficiaries.none?

      notifications = beneficiaries.find_each.map do |beneficiary|
        {
          broadcast_id: broadcast.id,
          beneficiary_id: beneficiary.id,
          phone_number: beneficiary.phone_number,
          delivery_attempts_count: 1,
          status: :pending
        }
      end

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

    def batch_operation_account_settings_param
      "batch_operation_callout_population_parameters"
    end
  end
end
