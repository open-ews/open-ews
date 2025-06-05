class DownloadBroadcastAudioFile < ApplicationWorkflow
  class Error < Errors::ApplicationError; end

  attr_reader :broadcast

  def initialize(broadcast)
    super()
    @broadcast = broadcast
  end

  def call
    uri = URI.parse(broadcast.audio_url)
    broadcast.audio_file.attach(
      io: URI.open(uri),
      filename: File.basename(uri)
    )
  rescue OpenURI::HTTPError, URI::InvalidURIError, Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, Socket::ResolutionError
    raise(Error.new(code: :audio_download_failed))
  end
end
