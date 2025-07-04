require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenEWS
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

     # Please, add to the `ignore` list any other `lib` subdirectories that do
     # not contain `.rb` files, or that should not be reloaded or eager loaded.
     # Common ones are `templates`, `generators`, or `middleware`, for example.
     config.autoload_lib(ignore: %w[assets tasks templates])


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.app_settings = config_for(:app_settings)
    config.active_job.default_queue_name = config.app_settings.fetch(:aws_sqs_default_queue_name)
    Rails.application.routes.default_url_options[:host] = config.app_settings.fetch(:app_url_host)
    config.action_mailer.default_url_options = { host: config.app_settings.fetch(:app_url_host) }

    config.exceptions_app = self.routes
  end
end

require "simple_form_components"
