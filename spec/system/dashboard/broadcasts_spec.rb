require "rails_helper"

RSpec.describe "Broadcasts" do
  it "can list broadcasts" do
    user = create(:user)
    broadcast = create(
      :broadcast,
      :pending,
      account: user.account
    )
    other_broadcast = create(:broadcast)

    sign_in(user)
    visit dashboard_broadcasts_path

    expect(page).to have_title("Broadcasts")

    expect(page).to have_content_tag_for(broadcast)
    expect(page).not_to have_content_tag_for(other_broadcast)
  end

  it "can create a broadcast attaching an audio file", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    select("Voice", from: "Channel")
    attach_file("Audio file", Rails.root + file_fixture("test.mp3"))

    # Add a beneficiary filter
    within("#beneficiary_filter_gender") do
      check(class: "form-check-input")
      select("Equals", from: "broadcast[beneficiary_filter][gender][operator]")
      select("M", from: "broadcast[beneficiary_filter][gender][value]")
    end

    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    within("#beneficiary_filter_gender") do
      expect(page).to have_selector("input.field-name[value='Gender']")
      expect(page).to have_selector("input.field-operator[value='Equals']")
      expect(page).to have_selector("input.field-value[value='M']")
    end
  end

  it "can update a broadcast", :js do
    user = create(:user)
    broadcast = create(
      :broadcast,
      account: user.account,
      beneficiary_filter: {
        disability_status: { eq: 'normal' }
      },
    )

    sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    within("#beneficiary_filter_gender") do
      check(class: "form-check-input")
      select("Equals", from: "broadcast[beneficiary_filter][gender][operator]")
      select("M", from: "broadcast[beneficiary_filter][gender][value]")
    end

    click_on "Save"

    expect(page).to have_text("Broadcast was successfully updated.")
    within("#beneficiary_filter_gender") do
      expect(page).to have_selector("input.field-name[value='Gender']")
      expect(page).to have_selector("input.field-operator[value='Equals']")
      expect(page).to have_selector("input.field-value[value='M']")
    end
    within("#beneficiary_filter_disability_status") do
      expect(page).to have_selector("input.field-name[value='Disability Status']")
      expect(page).to have_selector("input.field-operator[value='Equals']")
      expect(page).to have_selector("input.field-value[value='normal']")
    end
  end

  it "can delete a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Delete"

    expect(page).to have_text("Broadcast was successfully destroyed.")
    expect(page).to have_current_path(dashboard_broadcasts_path)
  end
end
