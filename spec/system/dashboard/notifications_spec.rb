require "rails_helper"

RSpec.describe "Notifications" do
  it "can list all notifications for a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, :completed, account: user.account)
    notification = create(:notification, :pending, broadcast:)
    create(:notification, :failed, broadcast:)
    create(:notification, :succeeded, broadcast:)
    other_notification = create(:notification, broadcast: create(:broadcast, account: user.account))

    account_sign_in(user)
    visit(dashboard_broadcast_path(broadcast))

    click_on("More")
    click_on("Notifications")

    expect(page).to have_title("Notifications for broadcast ##{broadcast.id}")
    expect(page).to have_link(broadcast.id.to_s, href: dashboard_broadcast_path(broadcast))
    expect(page).to have_content_tag_for(notification)
    expect(page).not_to have_content_tag_for(other_notification)
  end

  it "can show a notification" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)
    notification = create(:notification, broadcast:)

    account_sign_in(user)
    visit(dashboard_broadcast_notifications_path(broadcast))
    click_on(notification.id.to_s)

    expect(page).to have_title("Notification")
    expect(page).to have_content(notification.id)
    expect(page).to have_content("Broadcast")
    expect(page).to have_link(
      notification.broadcast_id.to_s,
      href: dashboard_broadcast_path(notification.broadcast)
    )
  end
end
