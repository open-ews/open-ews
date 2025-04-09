class AddAccountIdToPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    add_reference(:phone_calls, :account, foreign_key: true, null: false)
  end
end
