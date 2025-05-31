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

  def page_title(title:, &block)
    content_for(:page_title, title)

    content_tag(:div, class: "card-header d-flex justify-content-between align-items-center") do
      content = "".html_safe
      content += content_tag(:span, title, class: "h2")

      if block_given?
        content += content_tag(:div, id: "page_actions", class: "card-header-actions") do
          capture(&block)
        end
      end

      content
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

  def related_link_to(title, url, options = {})
    options[:class] ||= ""
    options[:class] << " dropdown-item"

    link_to(title, url, options)
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

  def json_attribute_value(json)
    content_tag(:pre) do
      content_tag(:code) do
        JSON.pretty_generate(json)
      end
    end
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
end
