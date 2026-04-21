Sentry.init do |config|
  config.dsn = Rails.configuration.app_settings[:sentry_dsn]
  config.traces_sample_rate = 0.1
end
