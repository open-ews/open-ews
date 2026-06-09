class Account < ApplicationRecord
  LOGO_CONTENT_TYPES = %w[image/jpg image/png].freeze

  has_one :access_token, -> { where(scopes: :write) }, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id
  has_many :oauth_applications, class_name: "Doorkeeper::Application", foreign_key: :owner_id
  has_many :users
  has_many :beneficiaries
  has_many :beneficiary_groups
  has_many :broadcasts
  has_many :events
  has_many :notifications, through: :broadcasts
  has_many :webhook_endpoints, through: :oauth_applications

  before_create :set_default_settings

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze
  enumerize :supported_channels, in: Broadcast.channel.values, multiple: true
  enumerize :dashboard_broadcast_beneficiary_filter_whitelist, in: FieldDefinitions::BeneficiaryFields.map(&:name), multiple: true

  has_one_attached :logo

  def api_key
    access_token.token
  end

  def configured_for_broadcasts?
    somleng_account_sid.present? && somleng_auth_token.present? && notification_phone_number.present?
  end

  def subdomain_host
    uri = Addressable::URI.parse(Rails.application.routes.url_helpers.dashboard_root_url(subdomain: "#{subdomain}.#{AppSettings.fetch(:app_subdomain)}"))
    uri.port.present? ? "#{uri.host}:#{uri.port}" : uri.host
  end

  private

  def set_default_settings
    self.delivery_attempt_queue_limit ||= 200
    self.max_delivery_attempts_for_notification ||= 3
  end
end
