class DashboardSummary
  attr_reader :account

  def initialize(account)
    @account = account
  end

  def total_beneficiaries
    @total_beneficiaries ||= account.beneficiaries.count
  end

  def new_beneficiaries_from_last_month
    account.beneficiaries.where(created_at: 1.month.ago..).count
  end

  def new_beneficiaries_from_last_month_percentage
    return 0 if total_beneficiaries.zero?

    (new_beneficiaries_from_last_month.to_f / total_beneficiaries) * 100
  end

  def total_succeeded_notifications
    @total_succeeded_notifications ||= account.notifications.where(status: :succeeded).count
  end

  def new_succeeded_notifications_from_last_month
    account.notifications.where(status: :succeeded, created_at: 1.month.ago..).count
  end

  def new_succeeded_notifications_from_last_month_percentage
    return 0 if total_succeeded_notifications.zero?

    (new_succeeded_notifications_from_last_month.to_f / total_succeeded_notifications) * 100
  end

  def total_broadcasts
    @total_broadcasts ||= account.broadcasts.count
  end

  def new_broadcasts_from_last_month
    account.broadcasts.where(created_at: 1.month.ago..).count
  end

  def new_broadcasts_from_last_month_percentage
    return 0 if total_broadcasts.zero?

    (new_broadcasts_from_last_month.to_f / total_broadcasts) * 100
  end
end
