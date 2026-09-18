class ChangeColumnNullOnAccountsDashboardBroadcastBeneficiaryFilterWhitelist < ActiveRecord::Migration[8.1]
  def change
    change_column_null(:accounts, :dashboard_broadcast_beneficiary_filter_whitelist, true)
    change_column_default(:accounts, :dashboard_broadcast_beneficiary_filter_whitelist, nil)
  end
end
