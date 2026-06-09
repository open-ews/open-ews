class AddDashboardBroadcastBeneficiaryFilterWhitelistToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column(
      :accounts,
      :dashboard_broadcast_beneficiary_filter_whitelist,
      :string,
      array: true,
      null: false,
      default: []
    )
  end
end
