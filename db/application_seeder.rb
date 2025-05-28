class ApplicationSeeder
  USER_PASSWORD = "OpenEWS1234!".freeze
  USER_EMAIL = "user@example.com".freeze

  def seed!
    account = Account.first_or_create!(name: "My Account", iso_country_code: "KH")
    access_token = account.access_tokens.first_or_create!(created_by: account)

    user = create_user(account:)
    puts(<<~INFO)
      Dashboard URL:    http://localhost:3000
      User Email:       #{user.email}
      User Password:    #{USER_PASSWORD}
      API Endpoint:     http://api.lvh.me:3000/v1
      API Key:          #{access_token.token}
    INFO
  end

  private

  def create_user(**params)
    existing_user = User.find_by(email: USER_EMAIL)

    return existing_user if existing_user.present?

    User.create!(email: USER_EMAIL, password: USER_PASSWORD, **params)
  end
end
