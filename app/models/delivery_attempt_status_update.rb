DeliveryAttemptStatusUpdate = Data.define(:channel, :status) do
  def desired_status
    case channel.to_sym
    when :voice
      status == "completed" ? "completed" : "failed"
    when :sms
      status.in?(["delivered", "sent"]) ? "completed" : "failed"
    end
  end
end
