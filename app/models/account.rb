class Account < ApplicationRecord
  has_one :access_token, class_name: "Doorkeeper::AccessToken", foreign_key: :resource_owner_id
  has_many :users
  has_many :beneficiaries
  has_many :beneficiary_groups
  has_many :broadcasts
  has_many :events

  has_many :batch_operations, class_name: "BatchOperation::CalloutPopulation"

  before_create :set_default_settings

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze
  validates :iso_country_code, presence: true

  def api_key
    access_token.token
  end

  def configured_for_broadcasts?
    somleng_account_sid.present? && somleng_auth_token.present? && notification_phone_number.present?
  end

  private

  def set_default_settings
    self.delivery_attempt_queue_limit ||= 200
    self.max_delivery_attempts_for_notification ||= 3
  end
end
