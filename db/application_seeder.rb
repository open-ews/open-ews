class ApplicationSeeder
  USER_PASSWORD = "OpenEWS1234!".freeze
  USER_EMAIL = "user@example.com".freeze
  ACCOUNT_NAME = "My Alerting Authority".freeze
  ACCOUNT_SUBDOMAIN = ACCOUNT_NAME.parameterize.freeze
  ACCOUNT_COUNTRY = "KH".freeze

  def seed!
    account = Account.first_or_create!(
      name: ACCOUNT_NAME,
      iso_country_code: ACCOUNT_COUNTRY,
      subdomain: ACCOUNT_SUBDOMAIN,
      supported_channels: Broadcast.channel.values
    )
    access_token = account.access_token || account.create_access_token!
    user = create_user(account:)
    beneficiary = create_beneficiary(
      account:,
      iso_country_code: ACCOUNT_COUNTRY,
      phone_number: "+85512345678",
      metadata: {
        created_by: "application_seeder"
      }
    )

    puts(<<~INFO)
      Dashboard URL:    http://#{ACCOUNT_SUBDOMAIN}.app.lvh.me:3000
      User Email:       #{user.email}
      User Password:    #{USER_PASSWORD}
      API Endpoint:     http://api.lvh.me:3000/v1
      API Key:          #{access_token.token}
    INFO
  end

  private

  def create_beneficiary(**params)
    existing_beneficiary = Beneficiary.find_by(
      phone_number: params.fetch(:phone_number),
      account: params.fetch(:account)
    )

    return existing_beneficiary if existing_beneficiary.present?

    Beneficiary.create!(**params)
  end

  def create_user(**params)
    existing_user = User.find_by(email: USER_EMAIL)

    return existing_user if existing_user.present?

    User.create!(name: "John Doe", email: USER_EMAIL, password: USER_PASSWORD, confirmed_at: Time.current, **params)
  end
end
