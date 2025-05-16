class BroadcastSummary
  extend ActiveModel::Translation
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :broadcast

  def initialize(broadcast)
    self.broadcast = broadcast
  end

  def notifications_count
    notifications.count
  end

  def notifications_still_to_be_called
    notifications.where(status: :pending).count
  end

  def completed_calls
    delivery_attempts.where(status: :succeeded).count
  end

  def failed_calls
    delivery_attempts.where(status: :failed).count
  end

  private

  def notifications
    broadcast.notifications
  end

  def delivery_attempts
    broadcast.delivery_attempts
  end
end
