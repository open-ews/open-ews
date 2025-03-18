require "rails_helper"

RSpec.resource "Broadcasts"  do
  get "/v1/broadcasts/:broadcast_id/audio_file" do
    example "Get a broadcast's audio file" do
      account = create(:account)
      broadcast = create(:broadcast, account:, audio_file: file_fixture("test.mp3"))

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".mp3")
    end

    example "Handle when broadcast's audio file is not available", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:, audio_file: nil)

      set_authorization_header_for(account)
      do_request(broadcast_id: broadcast.id)

      expect(response_status).to eq(406)
    end
  end
end
