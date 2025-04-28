require "rails_helper"

RSpec.describe "Callouts", :aggregate_failures do
  it "can list broadcasts" do
    user          = create(:user)
    broadcast       = create(
      :broadcast,
      :pending,
      account: user.account
    )
    other_broadcast = create(:broadcast)

    sign_in(user)
    visit dashboard_broadcasts_path

    expect(page).to have_title("Callouts")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_broadcast_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(broadcast)
      expect(page).not_to have_content_tag_for(other_broadcast)
      expect(page).to have_content("#")
      expect(page).to have_link(
        broadcast.id.to_s,
        href: dashboard_broadcast_path(broadcast)
      )
    end
  end

  it "create and start a broadcast", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    expect(page).to have_title("New Callout")

    fill_in("Audio URL", with: "https://www.example.com/sample.mp3")
    select("Voice", from: "Channel")

    click_on("Create Callout")

    expect(page).to have_content("Callout was successfully created.")
  end

  it "can create a broadcast attaching an audio file" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))
    select("Voice", from: "Channel")
    click_on("Create Callout")

    expect(page).to have_content("Callout was successfully created.")
  end

  it "can update a broadcast", :js do
    user = create(:user)
    broadcast = create(
      :broadcast,
      account: user.account
    )

    sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    expect(page).to have_title("Edit Callout")

    click_on "Save"

    expect(page).to have_text("Callout was successfully updated.")
  end

  it "can delete a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_broadcasts_path, ignore_query: true)
    expect(page).to have_text("Callout was successfully destroyed.")
  end

  it "can show a broadcast" do
    user = create(:user)
    broadcast = create(
      :broadcast,
      :pending,
      account: user.account,
      audio_file: file_fixture("test.mp3"),
      audio_url: "https://example.com/audio.mp3"
    )

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    expect(page).to have_title("Callout #{broadcast.id}")

    within("#page_actions") do
      expect(page).to have_link("Edit", href: edit_dashboard_broadcast_path(broadcast))
    end

    within(".broadcast") do
      expect(page).to have_content(broadcast.id)
      expect(page).to have_link(broadcast.audio_url, href: broadcast.audio_url)
    end

    within("#broadcast_summary") do
      expect(page).to have_content("Callout Summary")
      expect(page).to have_link("Refresh", href: dashboard_broadcast_path(broadcast))
      expect(page).to have_content("Participants")
      expect(page).to have_content("Participants still to be called")
      expect(page).to have_content("Completed calls")
      expect(page).to have_content("Failed calls")
    end
  end
end
