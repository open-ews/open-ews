module CSVSerializers
  class NotificationSerializer < ResourceSerializer
    attributes :phone_number, :status, :delivery_attempts_count, :broadcast_id, :beneficiary_id
  end
end
