class AppSettings
  class << self
    def fetch(...)
      config.fetch(...)
    end

    def [](...)
      config.[](...)
    end

    private

    def config
      Rails.configuration.app_settings
    end
  end
end
