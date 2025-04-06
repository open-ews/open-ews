class Account < ApplicationRecord
  include MetadataHelpers

  store_accessor :settings

  accepts_nested_key_value_fields_for :settings

  has_many :access_tokens,
           foreign_key: :resource_owner_id,
           dependent: :restrict_with_error

  has_many :users,
           dependent: :restrict_with_error

  has_many :beneficiaries, dependent: :restrict_with_error
  has_many :broadcasts, dependent: :restrict_with_error

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  delegate :twilio_account_sid?, to: :class

  validates :somleng_account_sid,
            uniqueness: { case_sensitive: false },
            allow_nil: true

  before_create :set_default_settings

  strip_attributes

  def delivery_attempt_queue_limit
    [ settings.fetch("phone_call_queue_limit").to_i, 1000 ].max
  end

  def from_phone_number
    settings.fetch("from_phone_number")
  end

  def max_delivery_attempts_for_alert
    settings.fetch("max_phone_calls_for_callout_participation", 3).to_i
  end

  private

  def set_default_settings
    settings["from_phone_number"] ||= "1234"
    settings["phone_call_queue_limit"] ||= 200
    settings["max_phone_calls_for_callout_participation"] ||= 3
  end
end
