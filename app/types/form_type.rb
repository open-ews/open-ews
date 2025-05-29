class FormType < ActiveRecord::Type::Value
  attr_reader :form

  def initialize(form:, **)
    @form = form
    super(**)
  end

  def cast(value)
    return value if value.is_a?(form)

    form.new(value)
  end
end
