require "rails_helper"

RSpec.describe "Broadcasts" do
  it "list broadcasts", :js do
    user = create(:user)
    pending_broadcast = create(
      :broadcast,
      :pending,
      account: user.account
    )
    completed_broadcast = create(
      :broadcast,
      :completed,
      account: user.account
    )
    other_broadcast = create(:broadcast)

    account_sign_in(user)
    visit dashboard_broadcasts_path

    expect(page).to have_title("Broadcasts")
    expect(page).to have_content_tag_for(pending_broadcast)
    expect(page).to have_content_tag_for(completed_broadcast)
    expect(page).not_to have_content_tag_for(other_broadcast)

    click_on "Filters"
    select_filter("Status", operator: "Equals", select: "Pending")
    click_on "Apply Filters"

    expect(page).to have_content_tag_for(pending_broadcast)
    expect(page).not_to have_content_tag_for(completed_broadcast)
    expect(page).not_to have_content_tag_for(other_broadcast)
  end

  it "create a broadcast", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)
    create_beneficiary_group(name: "My group", account:)
    create_beneficiary_group(name: "My other group", account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path

    select("Voice", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    select_list("My group", "My other group", from: "Beneficiary groups")
    select_filter("Gender", operator: "Equals", select: "Male")
    select_filter("Commune")
    select_tree("Banteay Meanchey", "Mongkol Borei", "Banteay Neang")

    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Male")
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_content("Banteay Meanchey")
      expect(page).to have_content("Mongkol Borei")
      expect(page).to have_content("Banteay Neang")
    end
  end

  it "create an SMS broadcast", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path
    select("SMS", from: "Channel")
    fill_in("Message", with: "Test message")
    select_filter("Gender", operator: "Equals", select: "Male")
    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    expect(page).to have_content("SMS")
    expect(page).to have_content("Test message")
  end

  it "create a broadcast from an unsupported country", :js do
    account = create(:account, iso_country_code: "US")
    user = create(:user, account:)

    account_sign_in(user)
    visit new_dashboard_broadcast_path

    select("Voice", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    select_filter("Country", operator: "Equals", select: "United States of America")
    select_filter("ISO region code", operator: "Equals", fill_in: "US-AL")
    select_filter("Administrative division level 2 code", operator: "Equals", fill_in: "001")
    select_filter("Administrative division level 2 name", operator: "Starts with", fill_in: "Autauga")

    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")

    within("#beneficiary_filter_iso_country_code") do
      expect(page).to have_field(with: "Country")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "United States of America (the)")
    end
    within("#beneficiary_filter_iso_region_code") do
      expect(page).to have_field(with: "ISO region code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "US-AL")
    end
    within("#beneficiary_filter_administrative_division_level_2_code") do
      expect(page).to have_field(with: "Administrative division level 2 code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "001")
    end
    within("#beneficiary_filter_administrative_division_level_2_name") do
      expect(page).to have_field(with: "Administrative division level 2 name")
      expect(page).to have_field(with: "Starts with")
      expect(page).to have_field(with: "Autauga")
    end
  end

  it "update a broadcast", :js, :selenium_chrome do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)
    create_beneficiary_group(name: "My other group", account:)
    broadcast = create(
      :broadcast,
      :with_attached_audio,
      audio_filename: "test.mp3",
      account: user.account,
      beneficiary_groups: [ create_beneficiary_group(name: "My group", account:) ],
      beneficiary_filter: {
        phone_number: { in: [ "855715100850",  "855715100851" ] },
        disability_status: { eq: 'normal' },
        "address.administrative_division_level_3_code": { in: [ "120101" ] },
      }
    )

    account_sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    expect(page).to have_link("test.mp3")
    expect(page).to have_select("Channel", disabled: true)

    select_list("My other group", from: "Beneficiary groups")
    select_filter("Gender", operator: "Equals", select: "Male")
    select_filter("Disability status", operator: "Equals", select: "Disabled")
    select_filter("ISO language code", operator: "Equals", fill_in: "khm")
    select_tree("Banteay Meanchey", "Mongkol Borei", "Banteay Neang")

    click_on "Update Broadcast"

    expect(page).to have_content("Broadcast was successfully updated.")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Male")
    end
    within("#beneficiary_filter_disability_status") do
      expect(page).to have_field(with: "Disability status")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Disabled")
    end
    within("#beneficiary_filter_iso_language_code") do
      expect(page).to have_field(with: "ISO language code")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "khm")
    end
    within("#beneficiary_filter_phone_number") do
      expect(page).to have_field(with: "Phone number")
      expect(page).to have_field(with: "In")
      expect(page).to have_select(selected: [ "855715100850",  "855715100851" ])
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_content("Banteay Meanchey")
      expect(page).to have_content("Mongkol Borei")
      expect(page).to have_content("Banteay Neang")
      expect(page).to have_content("Phnom Penh")
      expect(page).to have_content("Chamkar Mon")
      expect(page).to have_content("Tonle Basak")
    end
  end

  it "delete a broadcast" do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Delete"

    expect(page).to have_text("Broadcast was successfully destroyed.")
    expect(page).to have_current_path(dashboard_broadcasts_path)
  end

  it "start a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    user = create(:user, account:)
    create(:beneficiary, account:, gender: "M")

    broadcast = create(
      :broadcast,
      :pending,
      :with_attached_audio,
      account: account,
      beneficiary_filter: {
        gender: { eq: "M" }
      }
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    perform_enqueued_jobs do
      click_on "Start"
    end

    expect(page).to have_text("Broadcast was successfully updated.")
    expect(page).to have_text("Running")
  end

  it "stop a broadcast" do
    account = create(:account)
    user = create(:user, account:)
    broadcast = create(:broadcast, :running, account:)

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    click_on "Stop"

    expect(page).to have_text("Broadcast was successfully updated.")
    expect(page).to have_text("Stopped")
  end

  it "fail to start a broadcast" do
    account = create(:account, :configured_for_broadcasts)
    user = create(:user, account:)
    create(:beneficiary, account:, gender: "F")

    broadcast = create(
      :broadcast,
      :pending,
      :with_attached_audio,
      account: account,
      beneficiary_filter: {
        gender: { eq: "M" }
      }
    )

    account_sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    perform_enqueued_jobs do
      click_on "Start"
    end

    expect(page).to have_text("Errored")
    expect(page).to have_text("No beneficiaries match the filters")
  end

  def select_tree(*values)
    within("#broadcast_beneficiary_filter_administrative_division_level_3_code") do
      values.each do
        title = find("a", text: it)
        if it == values.last
          title.find(:xpath, "preceding-sibling::input[@type='checkbox'][1]").click
        else
          title.find(:xpath, 'preceding-sibling::a[1]').click
        end
      end
    end
  end

  def create_beneficiary_group(attributes)
    beneficiary_group = create(:beneficiary_group, **attributes)
    create(
      :beneficiary_group_membership,
      beneficiary_group: beneficiary_group,
      beneficiary: create(:beneficiary, account: beneficiary_group.account)
    )
    beneficiary_group
  end
end
