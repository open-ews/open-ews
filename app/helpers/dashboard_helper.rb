module DashboardHelper
  def broadcast_status(broadcast)
    case broadcast.status
    when "pending", "queued"
      broadcast_badge_status(broadcast.status, color: "gray", icon: "clock")
    when "running"
      broadcast_badge_status(broadcast.status, color: "blue", icon: "hourglass-high")
    when "stopped"
      broadcast_badge_status(broadcast.status, color: "yellow", icon: "player-pause")
    when "completed"
      broadcast_badge_status(broadcast.status, color: "green", icon: "check")
    when "errored"
      broadcast_badge_status(broadcast.status, color: "red", icon: "alert-triangle")
    end
  end

  def broadcast_badge_status(status, color:, icon:)
    content_tag(:span, class: "badge bg-#{color} text-#{color}-fg") do
      content_tag(:i, nil, class: "icon ti ti-#{icon}") + t("broadcasts.status.#{status}")
    end
  end
end
