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

    enumerize :event, in: [ :air_raid, :flood, :earthquake ]
    enumerize :urgency, in: [ :immediate, :expected, :future ]
    enumerize :severity, in: [ :extreme, :severe, :moderate, :minor ]

    def model_name
      ActiveModel::Name.new(self, nil, "FakeAlert")
    end

    class << self
      def all
        @alerts ||= [
          Alert.new(
            id: "3",
            event: "air_raid",
            headline: "Air raid warning for Bahawalpur",
            description: "An immediate evacuation of Bahawalpur is required due to an imminent air raid.",
            instruction: "Everyone in Bahawalpur should quickly, yet safely, go to Multan by vehicle via route N5 to Sawi Masjid. Do not block access roads or tracks. Do not take personal belongings other than critical medication and personal documents. Provide pets and other livestock with food and water. Stay out of the evacuation zone until it has been announced it is safe for you to return. Persons in areas not listed for evacuation should remain in place, and stay alert for changing conditions. Listen to the media for further instruction from local authorities.",
            urgency: "immediate",
            severity: "extreme",
            created_at: Time.current
          ),
          Alert.new(
            id: "2",
            event: "flood",
            headline: "Flood warning for Punjab",
            description: "Heavy rain may cause floods in low lying areas.",
            instruction: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
            urgency: "expected",
            severity: "moderate",
            created_at: 1.day.ago
          ),
          Alert.new(
            id: "1",
            event: "earthquake",
            headline: "Earthquake warning for Balochistan",
            description: "Imminent earthquake expected in Balochistan. Residents should take immediate precautions.",
            instruction: "Remain calm. If indoors, drop to your knees, cover your head and neck, and hold on to your cover. If on the ground floor of an adobe house with a heavy roof, exit quickly. If outdoors, find a clear spot and drop to your knees to prevent falling. If in a vehicle, go to a clear location and pull over. After the main shaking stops, if you are indoors, move cautiously and evacuate the building. Expect aftershocks.",
            urgency: "immediate",
            severity: "severe",
            created_at: 2.days.ago
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
