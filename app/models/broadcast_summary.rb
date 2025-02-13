class BroadcastSummary
  extend ActiveModel::Translation
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :broadcast

  def initialize(broadcast)
    self.broadcast = broadcast
  end

  def participations
    callout_participations.count
  end

  def participations_still_to_be_called
    callout_participations.still_trying(broadcast.account.max_phone_calls_for_callout_participation).count
  end

  def completed_calls
    phone_calls.completed.count
  end

  def not_answered_calls
    phone_calls.not_answered.count
  end

  def busy_calls
    phone_calls.busy.count
  end

  def failed_calls
    phone_calls.failed.count
  end

  def errored_calls
    phone_calls.errored.count
  end

  private

  def callout_participations
    broadcast.callout_participations
  end

  def phone_calls
    broadcast.phone_calls
  end
end
