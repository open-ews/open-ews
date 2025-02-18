require "rails_helper"

RSpec.describe Filter::Resource::Broadcast do
  it "filters by metadata" do
    broadcast = create(
      :broadcast,
      metadata: { "foo" => "bar", "bar" => "foo" }
    )

    expect(build_filter(metadata: { "foo" => "bar" }).resources).to eq([ broadcast ])
    expect(build_filter(metadata: { "foo" => "baz" }).resources).to be_empty
  end

  it "filters by created_at" do
    broadcast = create(:broadcast, created_at: Time.utc(2020, 1, 1, 9))

    # expect(build_filter(created_at_before: Time.utc(2020, 1, 1, 10)).resources).to be_present
    # expect(build_filter(created_at_after: Time.utc(2020, 1, 1, 8)).resources).to be_present
    # expect(build_filter(created_at_before: Time.utc(2020, 1, 1, 9)).resources).to be_empty
    # expect(build_filter(created_at_after: Time.utc(2020, 1, 1, 9)).resources).to be_empty
    # expect(build_filter(created_at_or_before: Time.utc(2020, 1, 1, 9)).resources).to be_present
    # expect(build_filter(created_at_or_after: Time.utc(2020, 1, 1, 9)).resources).to be_present
    expect(build_filter(created_at_or_before: "2020-01-01").resources).to be_present
    expect(build_filter(created_at_or_after: "2020-01-01").resources).to be_present
    expect(build_filter(created_at_before: "2020-01-01").resources).to be_empty
    expect(build_filter(created_at_after: "2020-01-01").resources).to be_empty

    expect(build_filter(created_at_after: "foobar").resources).to match_array([ broadcast ])
  end

  it "filters by status" do
    broadcast = create(:broadcast, status: :running)

    expect(build_filter(status: :running).resources).to match_array([ broadcast ])
    expect(build_filter(status: :created).resources).to be_empty
  end

  it "filters by call_flow_logic" do
    broadcast = create(:broadcast, call_flow_logic: "CallFlowLogic::HelloWorld")

    expect(build_filter(call_flow_logic: "CallFlowLogic::HelloWorld").resources).to match_array([ broadcast ])
    expect(build_filter(call_flow_logic: "CallFlowLogic::PlayMessage").resources).to be_empty
  end

  def build_filter(filter_attributes)
    Filter::Resource::Broadcast.new(
      { association_chain: Broadcast.all },
      filter_attributes
    )
  end
end
