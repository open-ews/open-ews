class FormType < ActiveRecord::Type::Value
  attr_reader :form, :options

  def initialize(form:, options: {}, **)
    @form = form
    @options = options
    super(**)
  end

  def cast(value)
    return value if value.is_a?(form)

    form.new(value)
  end
end
