require "rails_helper"
require Rails.root.join("db/application_seeder")

RSpec.describe ApplicationSeeder do
  describe "#seed!" do
    it "creates an account" do
      ApplicationSeeder.new.seed!

      expect(Account.count).to eq(1)
      expect(Account.first.access_tokens.count).to eq(1)
    end
  end
end
