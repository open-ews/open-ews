class AccountForm < ApplicationForm
  attribute :object, default: -> { Account.new }
  attribute :name, FormDataType.new
  attribute :country
  attribute :logo
  attribute :somleng_account_sid, FormDataType.new
  attribute :somleng_auth_token, FormDataType.new
  attribute :notification_phone_number, FormDataType.new
  attribute :subdomain, SubdomainType.new

  enumerize :country, in: Account.iso_country_code.values
  validates :name, presence: true
  validates :country, presence: true
  validates :subdomain, presence: true,
                        subdomain: { scope: ->(form) { Account.where.not(id: form.object.id) } }

  validate :validate_somleng_account_sid

  delegate :id, :new_record?, :persisted?, :subdomain_host, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(account)
    new(
      object: account,
      name: account.name,
      country: account.iso_country_code,
      logo: account.logo,
      somleng_account_sid: account.somleng_account_sid,
      somleng_auth_token: account.somleng_auth_token,
      notification_phone_number: account.notification_phone_number,
      subdomain: account.subdomain
    )
  end

  def save
    return false if invalid?

    object.name = name
    object.iso_country_code = country
    object.logo = logo if logo.present?
    object.somleng_account_sid = somleng_account_sid
    object.somleng_auth_token = somleng_auth_token
    object.notification_phone_number = notification_phone_number
    object.subdomain = subdomain

    object.save!
  end

  def validate_somleng_account_sid
    return if somleng_account_sid.blank?

    errors.add(:somleng_account_sid, :taken) if Account.exists?(subdomain)
  end
end
