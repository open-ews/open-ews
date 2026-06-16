class BroadcastChannelCapabilities
  attr_reader :channel

  AUDIO_CHANNELS = [ "voice_call", "audio" ].freeze
  TEXT_CHANNELS = [ "text_message" ].freeze
  DELIVERABLE_CHANNELS = [ "voice_call", "text_message" ].freeze

  def initialize(channel)
    @channel = channel.to_s
  end

  def audio?
    channel.in?(AUDIO_CHANNELS)
  end

  def text?
    channel.in?(TEXT_CHANNELS)
  end

  def deliverable?
    channel.in?(DELIVERABLE_CHANNELS)
  end
end
