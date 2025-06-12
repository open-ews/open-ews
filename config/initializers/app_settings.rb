class AppSettings
  class << self
    def app_uri
      Addressable::URI.parse(fetch(:app_url_host))
    end

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
