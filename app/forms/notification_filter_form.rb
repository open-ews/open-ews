class NotificationFilterForm < FilterForm
  self.filter_class = NotificationFilter

  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :delivery_attempts_count, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)
end
