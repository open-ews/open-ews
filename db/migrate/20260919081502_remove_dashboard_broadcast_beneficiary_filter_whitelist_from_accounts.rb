class RemoveDashboardBroadcastBeneficiaryFilterWhitelistFromAccounts < ActiveRecord::Migration[8.1]
  def change
    remove_column(
      :accounts,
      :dashboard_broadcast_beneficiary_filter_whitelist,
      :string,
      array: true
    )
  end
end
