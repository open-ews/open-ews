class RenameAlertsToNotifications < ActiveRecord::Migration[8.0]
  def change
    rename_table :alerts, :notifications
    rename_column :accounts, :max_delivery_attempts_for_alert, :max_delivery_attempts_for_notification
    rename_column :accounts, :alert_phone_number, :notification_phone_number
    rename_column :delivery_attempts, :alert_id, :notification_id
  end
end
