require "rails_helper"

RSpec.describe RunBatchOperationJob do
  it "runs the batch operation" do
    account = create(:account, :configured_for_broadcasts)
    broadcast = create(:broadcast, status: :queued, account:)
    callout_population = create(:callout_population, :queued, broadcast:)

    RunBatchOperationJob.perform_now(callout_population)

    expect(callout_population.reload).to be_finished
  end

  it "does not run the batch operation if it's already finished" do
    callout_population = create(:callout_population, :finished)

    RunBatchOperationJob.perform_now(callout_population)

    expect(callout_population).to be_finished
  end
end
