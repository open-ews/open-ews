class UserProfilePolicy < DashboardPolicy
  def read?
    user == record
  end

  def manage?
    user == record
  end
end
