require "rails_helper"

RSpec.describe GeocodeQuery do
  describe ".matching" do
    it "returns the scope matching the specified administrative division" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)
      _broadcast_with_no_target_areas = create(:broadcast)
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )
      create(
        :geocode_target_area,
        broadcast: non_matching_broadcast,
        path: [ "KH-2" ]
      )

      result = GeocodeQuery.new(Broadcast).matching(administrative_level: 1, geocode: [ "KH-1" ])

      expect(result).to contain_exactly(matching_broadcast)
    end
  end

  describe ".contains" do
    it "returns the scope containing the specified administrative divisions" do
      matching_broadcast = create(:broadcast)
      non_matching_broadcast = create(:broadcast)

      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1" ]
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102" ],
      )
      create(
        :geocode_target_area,
        broadcast: matching_broadcast,
        path: [ "KH-1", "0102", "010201" ]
      )
      create(
        :geocode_target_area,
        broadcast: non_matching_broadcast,
        path: [ "KH-2" ]
      )

      result = GeocodeQuery.new(Broadcast).contains(
        administrative_level: 3, geocode: [ "010201", "010202" ]
      )

      expect(result).to contain_exactly(matching_broadcast)
    end
  end
end
