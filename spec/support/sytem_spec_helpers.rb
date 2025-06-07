module SystemSpecHelpers
  def select_list(*values, from:)
    return values.each { select(it, from:) } if Capybara.current_driver == :rack_test

    control_wrapper = find_field(from, visible: false).find(:xpath, "..")
    control_wrapper.click

    values.each { control_wrapper.find(:xpath, "..//*[text()='#{it}']").click }
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
