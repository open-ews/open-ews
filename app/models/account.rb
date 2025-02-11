class Account < ApplicationRecord
  DEFAULT_PERMISSIONS_BITMASK = 0
  TWILIO_ACCOUNT_SID_PREFIX = "AC".freeze
  DEFAULT_PLATFORM_PROVIDER = "twilio".freeze
  PLATFORM_PROVIDERS = [ DEFAULT_PLATFORM_PROVIDER, "somleng" ].freeze
  DEFAULT_CALL_FLOW_LOGIC = "CallFlowLogic::HelloWorld".freeze

  include MetadataHelpers
  include HasCallFlowLogic

  store_accessor :settings

  accepts_nested_key_value_fields_for :settings

  bitmask :permissions,
          as: [
            :super_admin
          ],
          null: false

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

  has_many :callout_participations, through: :broadcasts

  has_many :phone_calls

  has_many :remote_phone_call_events,
           through: :phone_calls

  has_many :recordings

  delegate :twilio_account_sid?, to: :class

  validates :platform_provider_name,
            inclusion: {
              in: PLATFORM_PROVIDERS
            }, allow_nil: true

  validates :twilio_account_sid, :somleng_account_sid,
            uniqueness: { case_sensitive: false },
            allow_nil: true

  before_validation :set_call_flow_logic, on: :create
  before_create :set_default_settings

  strip_attributes

  def super_admin?
    permissions?(:super_admin)
  end

  def self.find_by_platform_account_sid(account_sid)
    find_by(
      twilio_account_sid?(account_sid) ? :twilio_account_sid : :somleng_account_sid => account_sid
    )
  end

  def platform_auth_token(account_sid)
    twilio_account_sid?(account_sid) ? twilio_auth_token : somleng_auth_token
  end

  def self.twilio_account_sid?(account_sid)
    account_sid.to_s.start_with?(TWILIO_ACCOUNT_SID_PREFIX)
  end

  def platform_provider
    @platform_provider ||= Somleng::PlatformProvider.new(
      account_sid: platform_configuration(:account_sid),
      auth_token: platform_configuration(:auth_token),
      api_host: platform_configuration(:api_host),
      api_base_url: platform_configuration(:api_base_url)
    )
  end

  def write_batch_operation_access_token
    access_tokens.with_permissions(:batch_operations_write).last
  end

  def phone_call_queue_limit
    [ settings.fetch("phone_call_queue_limit").to_i, 1000 ].max
  end

  def from_phone_number
    settings.fetch("from_phone_number")
  end

  def max_phone_calls_for_callout_participation
    settings.fetch("max_phone_calls_for_callout_participation").to_i
  end

  private

  def set_default_settings
    settings["from_phone_number"] ||= "1234"
    settings["phone_call_queue_limit"] ||= 200
    settings["max_phone_calls_for_callout_participation"] ||= 3
  end

  def set_call_flow_logic
    self.call_flow_logic ||= DEFAULT_CALL_FLOW_LOGIC
  end

  def platform_configuration(key)
    self["#{platform_provider_name}_#{key}"]
  end
end
