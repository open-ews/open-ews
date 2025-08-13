class AddMessageToBroadcast < ActiveRecord::Migration[8.0]
  def change
    add_column :broadcasts, :message, :text
  end
end
