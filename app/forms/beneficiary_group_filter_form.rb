class BeneficiaryGroupFilterForm < FilterForm
  self.filter_class = BeneficiaryGroupFilter

  attribute :name, FormType.new(form: FilterFieldForm)
end
