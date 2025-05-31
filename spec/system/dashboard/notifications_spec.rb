require "rails_helper"

RSpec.describe "Notifications" do
  it "can list all notifications for a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)
    notification = create(:notification, broadcast:)
    other_notification = create(:notification, broadcast: create(:broadcast, account: user.account))

    sign_in(user)
    visit(dashboard_broadcast_notifications_path(notification.broadcast))

    expect(page).to have_title("Notifications")
    within("#resources") do
      expect(page).to have_content_tag_for(notification)
      expect(page).not_to have_content_tag_for(other_notification)
    end
  end

  it "can show a notification" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    notification = create(
      :notification,
      broadcast: callout_population.broadcast
    )

    sign_in(user)
    visit(dashboard_broadcast_notification_path(notification.broadcast, notification))

    expect(page).to have_title("Notification")
    within(".notification") do
      expect(page).to have_content(notification.id)
      expect(page).to have_content("Broadcast")
      expect(page).to have_link(
        notification.broadcast_id.to_s,
        href: dashboard_broadcast_path(notification.broadcast)
      )
    end
  end
end
