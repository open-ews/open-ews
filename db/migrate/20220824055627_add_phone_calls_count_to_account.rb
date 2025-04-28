class AddPhoneCallsCountToAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :phone_calls_count, :integer, null: false, default: 0
  end
end
