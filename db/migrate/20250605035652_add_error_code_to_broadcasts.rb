class AddErrorCodeToBroadcasts < ActiveRecord::Migration[8.0]
  def change
    add_column(:broadcasts, :error_code, :string)

    reversible do |dir|
      dir.up do
        Broadcast.where(error_message: "No beneficiaries match the filters").update_all(error_code: "no_matching_beneficiaries")
      end
    end

    remove_column(:broadcasts, :error_message, :string)
  end
end
