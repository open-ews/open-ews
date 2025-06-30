require "rails_helper"

RSpec.describe ApproximateCount do
  describe ".approximate_count" do
    it "returns approximate count without filters" do
      create_list(:beneficiary, 20)

      db_analyze
      count = Beneficiary.approximate_count

      expect(count).to eq(20)
    end

    it "returns approximate count with account_id filter" do
      account = create(:account)
      other_account = create(:account)
      create_list(:beneficiary, 2, account: account)
      create_list(:beneficiary, 3, account: other_account)

      db_analyze
      count = Beneficiary.where(account_id: account.id).approximate_count

      expect(count).to eq(2)
    end
  end
end
