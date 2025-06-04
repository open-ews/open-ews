module ApplicationHelper
  def user_profile_image_url(user)
    user_email = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{user_email}?size=200"
  end

  def country_name(iso_country_code)
    return if iso_country_code.blank?

    country = ISO3166::Country[iso_country_code]
    country.translations[I18n.locale.to_s] || country.common_name || country.iso_short_name
  end

  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error, :alert then "alert alert-danger"
    end
  end

  def title(**options)
    default = options.fetch(:controller_name, controller_name).to_s
    default = default.singularize if options.fetch(:action_name, action_name).to_s != "index"
    default = default.to_s.humanize

    translate(
      :"titles.#{options.fetch(:controller_name, controller_name)}.#{options.fetch(:action_name, action_name)}",
      default:
    )
  end

  def sidebar_nav(text, path, icon_class:, link_options: {})
    is_active = request.path == path || (path != dashboard_root_path && request.path.start_with?(path))
    content_tag(:li, class: "nav-item #{"active" if is_active}") do
      link_to(path, class: "nav-link", **link_options) do
        content = "".html_safe
        content += content_tag(:i, nil, class: "nav-link-icon d-md-none d-lg-inline-block #{icon_class}", style: "font-size: 20px")
        content + " " + content_tag(:span, text, class: "nav-link-title")
      end
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end

  def treeview_address_data
    iso_country_code = current_account.iso_country_code

    Rails.cache.fetch("#{iso_country_code}-#{I18n.locale}") do
      CountryAddressData.address_data(iso_country_code).map { |locality| treeview_node(locality) }
    end
  end

  def treeview_node(locality)
    children = locality.subdivisions.map { |i| treeview_node(i) } if locality.subdivisions.present?

    {
      id: locality.value,
      text: I18n.locale == :en ? locality.name_en : locality.name_local,
      children: children
    }
  end

  def broadcast_status(broadcast)
    case broadcast.status
    when "pending", "queued"
      status_badge(broadcast.status_text, color: "gray", icon: "clock")
    when "running"
      status_badge(broadcast.status_text, color: "blue", icon: "hourglass-high")
    when "stopped"
      status_badge(broadcast.status_text, color: "yellow", icon: "player-stop-filled")
    when "completed"
      status_badge(broadcast.status_text, color: "green", icon: "check")
    when "errored"
      status_badge(broadcast.status_text, color: "red", icon: "alert-triangle")
    end
  end

  def notification_status(notification)
    case notification.status
    when "pending"
      status_badge(notification.status_text, color: "gray", icon: "clock")
    when "failed"
      status_badge(notification.status_text, color: "red", icon: "alert-triangle")
    when "succeeded"
      status_badge(notification.status_text, color: "green", icon: "check")
    end
  end

  def status_badge(text, color:, icon:)
    content_tag(:span, class: "badge bg-#{color} text-#{color}-fg") do
      content_tag(:i, nil, class: "icon ti ti-#{icon}") + text
    end
  end

  def format_phone_number(value)
    Phony.format(value)
  end
end
