class BroadcastFilterForm < ApplicationForm
  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)

  def self.model_name
    ActiveModel::Name.new(self, nil, "Filter")
  end
end
