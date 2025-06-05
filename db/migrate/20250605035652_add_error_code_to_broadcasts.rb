class AddErrorCodeToBroadcasts < ActiveRecord::Migration[8.0]
  def change
    add_column(:broadcasts, :error_code, :string)
    remove_column(:broadcasts, :error_message, :string)
  end
end
