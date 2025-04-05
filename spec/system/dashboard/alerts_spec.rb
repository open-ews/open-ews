require "rails_helper"

RSpec.describe "Alerts" do
  it "can list all alerts for a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)
    alert = create(:alert, broadcast:)
    other_alert = create(:alert, broadcast: create(:broadcast, account: user.account))

    sign_in(user)
    visit(dashboard_broadcast_alerts_path(alert.broadcast))

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(alert)
      expect(page).not_to have_content_tag_for(other_alert)
    end
  end

  it "can show a alert" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    alert = create(
      :alert,
      broadcast: callout_population.broadcast,
      callout_population:
    )

    sign_in(user)
    visit(dashboard_broadcast_alert_path(alert.broadcast, alert))

    expect(page).to have_title("Callout Participation #{alert.id}")

    within(".alert") do
      expect(page).to have_content(alert.id)

      expect(page).to have_link(
        alert.broadcast_id.to_s,
        href: dashboard_broadcast_path(alert.broadcast)
      )

      expect(page).to have_link(
        alert.beneficiary_id.to_s,
        href: dashboard_beneficiary_path(alert.beneficiary)
      )

      expect(page).to have_content("Callout")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Created at")
    end
  end
end
