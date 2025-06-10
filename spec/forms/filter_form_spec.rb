require "rails_helper"

RSpec.describe FilterForm do
  it "applies the filter to the scope" do
    pending_broadcast = create(:broadcast, :pending)
    _completed_broadcast = create(:broadcast, :completed)

    result = BroadcastFilterForm.new(
      status: {
        operator: "eq",
        value: "pending"
      }
    ).apply(Broadcast.all)

    expect(result.size).to eq(1)
    expect(result).to eq([ pending_broadcast ])
  end
end
