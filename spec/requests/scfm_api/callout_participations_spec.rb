require "rails_helper"

RSpec.resource "Callout Participations" do
  header("Content-Type", "application/json")

  get "/api/callouts/:callout_id/callout_participations" do
    example "List all Callout Participations for a callout", document: false do
      account = create(:account)
      broadcast = create(:broadcast, account:)
      notification = create(:notification, :succeeded, broadcast:)
      _other_notification = create(:notification, broadcast: create(:broadcast, account:))
      set_authorization_header_for(account)
      do_request(callout_id: broadcast.id)

      expect(json_response.size).to eq(1)
      expect(json_response.pluck("id")).to contain_exactly(
        notification.id,
      )
      expect(json_response.dig(0, "answered")).to be(true)
    end
  end
end
