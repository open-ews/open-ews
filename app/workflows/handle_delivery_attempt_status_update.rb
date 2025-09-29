class HandleDeliveryAttemptStatusUpdate < ApplicationWorkflow
  class DeliveryAttemptRetryPolicy
    TERMINAL_ERRORS = [ "phone_number_unreachable" ].freeze

    attr_reader :delivery_attempt

    def initialize(delivery_attempt)
      @delivery_attempt = delivery_attempt
    end

    def terminal?
      return true if delivery_attempt.error_code.in?(TERMINAL_ERRORS)

      delivery_attempt.notification.max_delivery_attempts_reached?
    end
  end

  class BeneficiaryTerminationPolicy
    TERMINAL_ERRORS = [ "phone_number_unreachable" ].freeze

    attr_reader :delivery_attempt

    def initialize(delivery_attempt)
      @delivery_attempt = delivery_attempt
    end

    def terminate?
      delivery_attempt.error_code.in?(TERMINAL_ERRORS)
    end
  end

  attr_reader :delivery_attempt, :status, :delivery_attempt_retry_policy, :beneficiary_termination_policy

  def initialize(delivery_attempt, status:, **options)
    super()
    @delivery_attempt = delivery_attempt
    @status = status
    @delivery_attempt_retry_policy = options.fetch(:delivery_attempt_retry_policy) { DeliveryAttemptRetryPolicy.new(delivery_attempt) }
    @beneficiary_termination_policy = options.fetch(:beneficiary_termination_policy) { BeneficiaryTerminationPolicy.new(delivery_attempt) }
  end

  def call
    return if delivery_attempt.completed?

    ApplicationRecord.transaction do
      case status
      when "completed"
        delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
        complete_notification(:succeeded)
        complete_broadcast
      when "failed"
        if delivery_attempt_retry_policy.terminal?
          complete_notification(:failed)
          complete_broadcast
          delete_beneficiary if beneficiary_termination_policy.terminate?
        else
          RetryNotificationJob.set(wait: 15.minutes).perform_later(notification)
        end

        delivery_attempt.transition_to!(:failed, touch: :completed_at)
      end
    end
  end

  private

  def notification
    delivery_attempt.notification
  end

  def broadcast
    delivery_attempt.broadcast
  end

  def complete_notification(status)
    notification.transition_to(status, touch: :completed_at)
  end

  def complete_broadcast
    broadcast.transition_to(:completed, touch: :completed_at) if broadcast.notifications.where(status: :pending).none?
  end

  def delete_beneficiary
    ExecuteWorkflowJob.perform_later(DeleteBeneficiary.to_s, delivery_attempt.beneficiary)
  end
end
