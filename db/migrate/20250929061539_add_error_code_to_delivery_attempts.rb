class AddErrorCodeToDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    add_column(:delivery_attempts, :error_code, :string)
    add_index(:delivery_attempts, [ :error_code, :beneficiary_id ], where: "error_code='phone_number_unreachable'")
  end
end
