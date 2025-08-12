require "rails_helper"

module CSVSerializers
  RSpec.describe BroadcastSerializer do
    it "serializes a broadcast" do
      expect(
        BroadcastSerializer.new(
          create(
            :broadcast,
            channel: :voice,
            audio_url: "https://www.example.com/test.mp3",
          )
        ).as_json
      ).to include(
        channel: "voice",
        audio_url: "https://www.example.com/test.mp3",
        message: nil,
      )
    end
  end
end
