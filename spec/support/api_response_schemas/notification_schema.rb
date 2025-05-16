module APIResponseSchema
  NotificationSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "notification")

    required(:attributes).schema do
      required(:phone_number).filled(:str?)
      required(:status).filled(:str?)
      required(:delivery_attempts_count).filled(:int?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end

    required(:relationships).schema do
      required(:broadcast).schema do
        required(:data).filled(:hash?)
      end
      required(:beneficiary).schema do
        required(:data).filled(:hash?)
      end
    end
  end
end
