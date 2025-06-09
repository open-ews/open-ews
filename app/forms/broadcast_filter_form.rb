class BroadcastFilterForm < FilterForm
  self.filter_class = BroadcastFilter

  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)
end
