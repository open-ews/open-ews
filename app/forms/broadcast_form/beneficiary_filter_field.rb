class BroadcastForm::BeneficiaryFilterField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :operator
  attribute :value
end
