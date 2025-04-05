class AddDurationToPhoneCalls < ActiveRecord::Migration[5.2]
  def change
    add_column(:remote_phone_call_events, :call_duration, :integer, null: false, default: 0)
    add_column(:phone_calls, :duration, :integer, null: false, default: 0)
  end
end
