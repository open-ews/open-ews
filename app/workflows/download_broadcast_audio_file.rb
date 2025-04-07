class DownloadBroadcastAudioFile < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def call
    uri = URI.parse(broadcast.audio_url)
    broadcast.audio_file.attach(
      io: URI.open(uri),
      filename: File.basename(uri)
    )
  rescue OpenURI::HTTPError, URI::InvalidURIError
    raise(Error, "Unable to download audio file")
  end
end
