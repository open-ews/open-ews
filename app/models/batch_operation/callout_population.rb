module BatchOperation
  class CalloutPopulation < Base
    include CustomRoutesHelper["batch_operations"]

    belongs_to :broadcast

    has_many :alerts, foreign_key: :callout_population_id, dependent: :restrict_with_error
    has_many :beneficiaries, through: :alerts

    store_accessor :parameters,
                   :contact_filter_params,
                   :remote_request_params

    hash_store_reader :remote_request_params
    hash_store_reader :contact_filter_params

    accepts_nested_key_value_fields_for :contact_filter_metadata

    validates :contact_filter_params, contact_filter_params: true

    def run!
      transaction do
        create_alerts
        create_delivery_attempts
      end
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

    def beneficiaries_scope
      Filter::Resource::Beneficiary.new(
        { association_chain: account.beneficiaries },
        contact_filter_params.with_indifferent_access
      ).resources.where.not(id: Alert.select(:beneficiary_id).where(broadcast:))
    end

    def create_alerts
      alerts = beneficiaries_scope.find_each.map do |beneficiary|
        {
          beneficiary_id: beneficiary.id,
          phone_number: beneficiary.phone_number,
          broadcast_id: broadcast.id,
          callout_population_id: id,
          status: :queued
        }
      end
      Alert.upsert_all(alerts) if alerts.any?
    end

    def create_delivery_attempts
      delivery_attempts = alerts.includes(:delivery_attempts).find_each.map do |alert|
        next if alert.delivery_attempts.any?

        {
          broadcast_id:,
          beneficiary_id: alert.beneficiary_id,
          alert_id: alert.id,
          phone_number: alert.phone_number,
          status: :created
        }
      end

      if delivery_attempts.any?
        DeliveryAttempt.upsert_all(delivery_attempts)
        Alert.where(id: delivery_attempts.pluck(:alert_id)).update_all(delivery_attempts_count: 1)
      end
    end

    def batch_operation_account_settings_param
      "batch_operation_callout_population_parameters"
    end
  end
end
