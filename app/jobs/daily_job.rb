class DailyJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_low_priority_queue_name)

  def perform
    PgHero.clean_query_stats
  end
end
