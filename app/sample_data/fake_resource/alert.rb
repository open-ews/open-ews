module FakeResource
  class Alert
    include ActiveModel::Model
    include ActiveModel::Attributes

    extend Enumerize

    attribute :id
    attribute :event
    attribute :headline
    attribute :description
    attribute :instruction
    attribute :urgency
    attribute :severity
    attribute :created_at, :datetime
    attribute :language
    attribute :area_description
    attribute :locations

    enumerize :event, in: [ :heat, :flood, :earthquake ]
    enumerize :urgency, in: [ :immediate, :expected, :future ]
    enumerize :severity, in: [ :extreme, :severe, :moderate, :minor ]
    enumerize :language, in: [ "English", "اُردُو" ]

    def model_name
      ActiveModel::Name.new(self, nil, "FakeAlert")
    end

    class << self
      def all
        @alerts ||= [
          Alert.new(
            id: "4",
            event: "flood",
            headline: "Flood warning for Punjab",
            description: "Heavy rain may cause floods in low lying areas.",
            instruction: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
            urgency: "expected",
            severity: "moderate",
            language: "English",
            area_description: "Bahawalpur Division",
            locations: [ "Rahim Yar Khan", "Bahawalnagar", "Bahawalpur" ],
            created_at: 24.hours.ago,
          ),
          Alert.new(
            id: "3",
            event: "heat",
            headline: "Extreme heat warning for Jacobabad.",
            description: "Temperature to exceed 45 degrees in Jacobabad.",
            instruction: "Avoid direct exposure to the sun. Protect yourself with lightweight, loose-fitting clothing. Stay hydrated. Cool yourself down. Check with your neighbors, friends, and those at risk.",
            urgency: "immediate",
            severity: "severe",
            language: "English",
            area_description: "Jacobabad District",
            locations: [ "Garhi Khairo Tehsil", "Jacobabad Tehsil", "Thul Tehsil" ],
            created_at: 48.hours.ago,
          ),
          Alert.new(
            id: "2",
            event: "earthquake",
            headline: "Earthquake warning for Balochistan",
            description: "Imminent earthquake expected in Balochistan. Residents should take immediate precautions.",
            instruction: "Remain calm. If indoors, drop to your knees, cover your head and neck, and hold on to your cover. If on the ground floor of an adobe house with a heavy roof, exit quickly. If outdoors, find a clear spot and drop to your knees to prevent falling. If in a vehicle, go to a clear location and pull over. After the main shaking stops, if you are indoors, move cautiously and evacuate the building. Expect aftershocks.",
            urgency: "immediate",
            severity: "severe",
            language: "English",
            area_description: "Quetta District",
            locations: [ "Zarghoon", "Chiltan", "Panjpai" ],
            created_at: 72.hours.ago
          ),
          Alert.new(
            id: "1",
            event: "flood",
            headline: "Flood warning for Azad Kashmir.",
            description: "Heavy rain may cause floods in low lying areas.",
            instruction: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
            urgency: "expected",
            severity: "moderate",
            language: "English",
            area_description: "Mirpur Division",
            locations: [ "Mirpur", "Kotli", "Bhimber" ],
            created_at: 96.hours.ago,
          )
        ]
      end

      def first
        all.first
      end

      def find(id)
        all.find(-> { raise(ActiveRecord::RecordNotFound) }) { it.id == id }
      end
    end
  end
end
