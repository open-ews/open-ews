class DeliveryAttemptStatusUpdate
  INCOMPLETE_STATUSES = {
    voice: [ "queued", "ringing", "in-progress" ],
    sms: [ "accepted", "scheduled", "queued", "sending" ]
  }.freeze

  SUCCEEDED_STATUSES = {
    voice: [ "completed" ],
    sms: [ "delivered", "sent" ]
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
