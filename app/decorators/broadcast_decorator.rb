class BroadcastDecorator < ApplicationDecorator
  ORDERED_STATUSES = %i[failed succeeded pending].freeze

  def notification_stats
    @notification_stats ||= begin
      stats = object.notifications.group(:status).count.symbolize_keys
      ORDERED_STATUSES.each_with_object({}) { |s, result| result[s] = stats.fetch(s, 0) }
    end
  end

  def notification_stats_percentage
    notification_stats.transform_values do |count|
      ((count.to_f / total_notifications_count) * 100).round
    end
  end

  def total_notifications_count
    @total_notifications_count ||= object.notifications.count
  end
end
