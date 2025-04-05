class DropRemotePhoneCallEvents < ActiveRecord::Migration[8.0]
  def change
    drop_table(:remote_phone_call_events)
  end
end
