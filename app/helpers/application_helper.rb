module ApplicationHelper
  NOTIFICATION_STATUSES = {
    pending: { color: "gray-200", icon: "clock" },
    failed: { color: "red", icon: "alert-triangle" },
    succeeded: { color: "green", icon: "check" }
  }.freeze

  BROADCAST_STATUSES = {
    pending: { color: "gray-200", icon: "clock" },
    queued: { color: "gray-200", icon: "clock" },
    running: { color: "blue", icon: "hourglass-high" },
    stopped: { color: "yellow", icon: "player-stop-filled" },
    completed: { color: "green", icon: "check" },
    errored: { color: "red", icon: "alert-triangle" }
  }.freeze

  IMPORT_STATUSES = {
    processing: { color: "gray-200", icon: "clock" },
    failed: { color: "red", icon: "alert-triangle" },
    succeeded: { color: "green", icon: "check" }
  }.freeze

  def user_profile_image_url(user)
    user_email = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{user_email}?size=200"
  end

  def account_logo(account, **options)
    if account.logo&.attached?
      image_tag(account.logo, alt: "#{account.name} Logo", **options)
    else
      image_tag("open-ews_landscape_logo.png", options)
    end
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
      default:,
      **options
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
    status = BROADCAST_STATUSES[broadcast.status.to_sym]
    status_badge(
      broadcast.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def notification_status(notification)
    status = NOTIFICATION_STATUSES[notification.status.to_sym]

    status_badge(
      notification.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def notification_status_color(status)
    NOTIFICATION_STATUSES[status.to_sym].fetch(:color)
  end

  def import_status(import)
    status = IMPORT_STATUSES[import.status.to_sym]

    status_badge(
      import.status_text,
      color: status.fetch(:color),
      icon: status.fetch(:icon)
    )
  end

  def status_badge(text, color:, icon:)
    content_tag(:span, class: "badge bg-#{color}-lt") do
      content_tag(:i, nil, class: "icon ti ti-#{icon}") + text
    end
  end

  def error_message_for(code)
    t("error_codes.#{code}", default: code.to_s.humanize)
  end

  def format_phone_number(value)
    Phony.format(value)
  end
end
