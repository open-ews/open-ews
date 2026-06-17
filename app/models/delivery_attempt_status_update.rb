class DeliveryAttemptStatusUpdate
  INCOMPLETE_STATUSES = {
    voice_call: [ "queued", "ringing", "in-progress" ],
    text_message: [ "accepted", "scheduled", "queued", "sending" ]
  }.freeze

  SUCCEEDED_STATUSES = {
    voice_call: [ "completed" ],
    text_message: [ "delivered", "sent" ]
  }.freeze

  COMPLETED = "completed".freeze
  FAILED = "failed".freeze

  attr_reader :channel, :status

  def initialize(channel:, status:)
    @channel = channel.to_sym
    @status = status
  end

  def desired_status
    return if incomplete?

    succeeded? ? COMPLETED : FAILED
  end

  private

  def incomplete?
    status.in?(INCOMPLETE_STATUSES.fetch(channel))
  end

  def succeeded?
    status.in?(SUCCEEDED_STATUSES.fetch(channel))
  end
end
