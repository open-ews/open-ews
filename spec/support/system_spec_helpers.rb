module SystemSpecHelpers
  def account_sign_in(user)
    set_app_host(user.account)
    sign_in(user)
  end

  def set_app_host(account)
    Capybara.app_host = "http://#{account.subdomain_host}"
  end

  def have_image(alt:)
    have_css("img[alt='#{alt}']")
  end

  def have_content_tag_for(model, model_name: nil)
    have_selector("##{model_name || model.class.to_s.underscore.tr('/', '_')}_#{model.id}")
  end

  def select_filter(name, **options)
    field = find_field(with: name, disabled: :all)
    filter_field_wrapper = field.find(:xpath, ".//ancestor::*[contains(@class, 'filter-field')]")
    filter_id = filter_field_wrapper[:id]

    filter_field_wrapper.find_field(type: "checkbox").check unless field.checked?

    select(options.fetch(:operator), from: "#{filter_id}_operator") if options[:operator].present?

    value_input_id = "#{filter_id}_value"
    if options[:select].present?
      select(options.fetch(:select), from: value_input_id)
    elsif options[:fill_in].present?
      fill_in(value_input_id, with: options.fetch(:fill_in))
    end
  end

  def select_list(*values, from:)
    return values.each { select(it, from:) } if Capybara.current_driver == :rack_test

    control_wrapper = find_field(from, visible: false).find(:xpath, "..")
    control_wrapper.click

    values.each { control_wrapper.find(:xpath, "..//*[text()='#{it}']").click }
  end
end

RSpec.configure do |config|
  config.include(SystemSpecHelpers, type: :system)
end
