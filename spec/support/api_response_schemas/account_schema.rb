module APIResponseSchema
  AccountSchema = Dry::Schema.JSON do
    required(:id).filled(:str?)
    required(:type).filled(eql?: "account")

    required(:attributes).schema do
      required(:somleng_account_sid).maybe(:str?)
      required(:somleng_auth_token).maybe(:str?)
    end
  end
end
