module SystemSpecHelpers
  def have_content_tag_for(model, model_name: nil)
    have_selector("##{model_name || model.class.to_s.underscore.tr('/', '_')}_#{model.id}")
  end

  def select_filter(name, **options)
    filter_namespace = options.fetch(:filter_namespace, "filter")
    filter_id = filter_field_id(name, filter_namespace:)

    within("##{filter_id}") do
      if options.fetch(:enable_filter, true)
        check("#{filter_id}_enabled")
      end

      select(options.fetch(:operator), from: "#{filter_id}_operator") if options[:operator].present?

      value_input_id = "#{filter_id}_value"
      if options[:select].present?
        select(options.fetch(:select), from: value_input_id)
      elsif options[:fill_in].present?
        fill_in(value_input_id, with: options.fetch(:fill_in))
      end
    end
  end

  def filter_field_id(name, filter_namespace:)
    [ filter_namespace, name.to_s.parameterize.underscore ].join("_")
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
