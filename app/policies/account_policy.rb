class AccountPolicy < ApplicationPolicy
  def read?
    account_owner?
  end

  def manage?
    account_owner?
  end
end
