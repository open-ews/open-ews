class DashboardSummary
  attr_reader :account

  class Stats
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def total_count
      @total_count ||= scope.approximate_count
    end

    def new_count
      @new_count ||= scope.where(created_at: 30.days.ago..).count
    end

    def new_count_percentage
      return 0 if total_count.zero?

      (new_count.to_f / total_count) * 100
    end
  end

  def initialize(account)
    @account = account
  end

  def beneficiaries_stats
    @beneficiaries_stats ||= Stats.new(account.beneficiaries)
  end

  def notifications_stats
    @notifications_stats ||= Stats.new(account.notifications.where(status: :succeeded))
  end

  def broadcasts_stats
    @broadcasts_stats ||= Stats.new(account.broadcasts)
  end

  def recent_broadcasts
    @recent_broadcasts ||= account.broadcasts
      .where(status: [ :running, :stopped, :completed ])
      .latest_first
      .limit(3)
      .map(&:decorated)
  end

  def last_12_months_notifications_stats
    @last_12_months_notifications_stats ||= begin
      actual_data = account.notifications
        .where(status: :succeeded, created_at: 12.months.ago.beginning_of_month..)
        .group("DATE_TRUNC('month', notifications.created_at)")
        .count
        .transform_keys { |month| month.strftime("%Y-%m") }

      # Generate all 12 months with zero counts (oldest to newest)
      12.downto(1).each_with_object({}) do |i, result|
        month = i.months.ago.beginning_of_month
        month_with_year = month.strftime("%Y-%m")
        month_name = I18n.l(month, format: "%b %Y")

        result[month_with_year] = {
          name: month_name,
          count: actual_data.fetch(month_with_year, 0)
        }
      end
    end
  end
end
