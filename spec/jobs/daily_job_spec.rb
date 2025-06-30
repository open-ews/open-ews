require "rails_helper"

RSpec.describe DailyJob do
  it "analyzes the database" do
    create(:beneficiary)

    DailyJob.perform_now

    expect(Beneficiary.approximate_count).to eq(1)
  end
end
