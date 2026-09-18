require "rails_helper"

module FieldDefinitions
  RSpec.describe BroadcastFilter do
    it "handles eq" do
      field_query = BroadcastFilter::ChannelFieldQuery.new(arel_column: Broadcast.arel_table[:channel])

      expect(
        field_query.to_arel(operator: :eq, value: "audio").to_sql
      ).to eq(Broadcast.arel_table[:channel].eq("audio").to_sql)

      expect(
        field_query.to_arel(operator: :eq, value: [ "audio" ]
      ).to_sql).to eq(Broadcast.arel_table[:channel].eq("audio").to_sql)

      expect(
        field_query.to_arel(operator: :eq, value: [ "audio", "text_message" ]
      ).to_sql).to eq(Broadcast.arel_table[:channel].eq("audio.text_message").to_sql)
    end

    it "handles contains" do
      field_query = BroadcastFilter::ChannelFieldQuery.new(arel_column: Broadcast.arel_table[:channel])

      expect(
        field_query.to_arel(operator: :contains, value: "audio").to_sql
      ).to eq(Broadcast.arel_table[:channel].in([ "audio" ]).to_sql)

      expect(
        field_query.to_arel(operator: :contains, value: [ "audio", "text_message" ]).to_sql
      ).to eq(Broadcast.arel_table[:channel].in([ "audio", "text_message" ]).to_sql)
    end
  end
end
