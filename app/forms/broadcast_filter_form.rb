class BroadcastFilterForm < FilterForm
  self.filter_class = BroadcastFilter

  attribute :name, FormType.new(form: FilterFieldForm)
  attribute :channels, FormType.new(form: FilterFieldForm)
  attribute :status, FormType.new(form: FilterFieldForm)
  attribute :created_at, FormType.new(form: FilterFieldForm)
  attribute :iso_region_code, FormType.new(form: FilterFieldForm)
  attribute :administrative_division_level_2_code, FormType.new(form: FilterFieldForm)
  attribute :administrative_division_level_3_code, FormType.new(form: FilterFieldForm)
  attribute :administrative_division_level_4_code, FormType.new(form: FilterFieldForm)
  attribute :administrative_division_level_5_code, FormType.new(form: FilterFieldForm)
end
