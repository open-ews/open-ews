class Account < ApplicationRecord
  has_many :access_tokens, foreign_key: :resource_owner_id
  has_many :users
  has_many :beneficiaries
  has_many :broadcasts

  before_create :set_default_settings

  strip_attributes

  def configured_for_broadcasts?(_channel:)
    somleng_account_sid.present? && somleng_auth_token.present? && alert_phone_number.present?
  end

  private

  def set_default_settings
    self.delivery_attempt_queue_limit ||= 200
    self.max_delivery_attempts_for_alert ||= 3
  end
end
