class BroadcastSummary
  extend ActiveModel::Translation
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :broadcast

  def initialize(broadcast)
    self.broadcast = broadcast
  end

  def alerts_count
    alerts.count
  end

  def alerts_still_to_be_called
    alerts.still_trying(broadcast.account.max_delivery_attempts_for_alert).count
  end

  def completed_calls
    delivery_attempts.where(status: :succeeded).count
  end

  def failed_calls
    delivery_attempts.where(status: :failed).count
  end

  def errored_calls
    delivery_attempts.where(status: :errored).count
  end

  private

  def alerts
    broadcast.alerts
  end

  def delivery_attempts
    broadcast.delivery_attempts
  end
end
