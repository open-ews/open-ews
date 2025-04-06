class RemoveColumnsFromAccount < ActiveRecord::Migration[8.0]
  def change
    remove_column(:accounts, :twilio_account_sid, :citext)
    remove_column(:accounts, :twilio_auth_token, :string)
    remove_column(:accounts, :somleng_api_host, :string)
    remove_column(:accounts, :somleng_api_base_url, :string)
    remove_column(:accounts, :platform_provider_name, :string)
    remove_column(:accounts, :permissions, :integer, default: 0)
    add_column(:accounts, :name, :string)
    add_column(:accounts, :delivery_attempt_queue_limit, :integer)
    add_column(:accounts, :alert_phone_number, :string)
    add_column(:accounts, :max_delivery_attempts_for_alert, :integer)

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          account.update_columns(
            name: account.metadata.fetch("name"),
            delivery_attempt_queue_limit: account.settings.fetch("phone_call_queue_limit").to_i,
            alert_phone_number: account.settings.fetch("from_phone_number"),
            max_delivery_attempts_for_alert: account.settings.fetch("max_phone_calls_for_callout_participation").to_i
          )
        end
      end
    end

    change_column_null(:accounts, :name, false)
    change_column_null(:accounts, :max_delivery_attempts_for_alert, false)
    change_column_null(:accounts, :delivery_attempt_queue_limit, false)
    remove_column(:accounts, :metadata, :jsonb, default: {}, null: false)
    remove_column(:accounts, :settings, :jsonb, default: {}, null: false)
  end
end
