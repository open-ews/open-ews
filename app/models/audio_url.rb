class AudioURL
  attr_reader :key, :host

  def initialize(options)
    @key = options.fetch(:key)
    @host = options.fetch(:host) { Rails.configuration.app_settings.fetch(:audio_host) }
  end

  def url
    uri = URI(host)
    uri.path = "/#{key}"
    uri.to_s
  end
end
