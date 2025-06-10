require "selenium/webdriver"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test

    Capybara.app_host = AppSettings.fetch(:app_url_host)
    Capybara.server = :puma, { Silent: true }
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
  end

  config.before(:each, :selenium_chrome, type: :system) do
    driven_by :selenium, using: :chrome
  end
end
