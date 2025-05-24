class BroadcastForm::BeneficiaryFilterField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :operator
  attribute :value

  def value=(val)
    val.is_a?(Array) ? super(val.reject(&:blank?)) : super
  end
end
