class DashboardSummary
  attr_reader :account

  class Stats
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def total_count
      @total_count ||= scope.count
    end

    def new_count
      @new_count ||= scope.where(created_at: 1.month.ago..).count
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
    @recent_broadcasts ||= account.broadcasts.order(created_at: :desc).where(status: [ :running, :stopped, :completed ]).limit(3)
  end
end
