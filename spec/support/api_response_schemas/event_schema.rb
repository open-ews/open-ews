module APIResponseSchema
  EventSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "event")

    required(:attributes).schema do
      required(:type).filled(:str?)
      required(:created_at).filled(:str?)
      required(:updated_at).filled(:str?)
    end
  end
end
