class BroadcastFilterForm < FilterForm
  self.filter_class = BroadcastFilter

  attribute :name, FormType.new(form: FilterFieldForm)
  attribute :channel, FormType.new(form: FilterFieldForm)
  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)
end
