require "rails_helper"
require Rails.root.join("db/application_seeder")

RSpec.describe ApplicationSeeder do
  it "seeds the database" do
    seeder = ApplicationSeeder.new

    seeder.seed!

    expect(Account.count).to eq(1)
    expect(Account.first).to have_attributes(
      api_key: be_present,
      users: contain_exactly(
        have_attributes(
          email: "user@example.com"
        )
      )
    )

    seeder.seed!

    expect(Account.count).to eq(1)
    expect(User.count).to eq(1)
  end
end
