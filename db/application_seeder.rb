class ApplicationSeeder
  def seed!
    account = Account.first_or_create!(name: "My Account")
    account.access_tokens.first_or_create!(created_by: account)
  end
end
