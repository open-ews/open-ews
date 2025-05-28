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

  it "shows the broadcast details" do
    account = create(:account, iso_country_code: "US")
    user = create(:user, account:)
    broadcast = create(
      :broadcast,
      account: account,
      beneficiary_filter: {
        disability_status: { eq: 'normal' },
        "address.administrative_division_level_3_code": { in: [ "120101" ] }
      }
    )

    sign_in(user)
    visit dashboard_broadcast_path(broadcast)

    within("#beneficiary_filter_disability_status") do
      expect(page).to have_field(with: "Disability status")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Normal")
    end
    within("#beneficiary_filter_administrative_division_level_3_code") do
      expect(page).to have_field(with: "Administrative division level 3 code")
      expect(page).to have_field(with: "In")
      expect(page).to have_field(with: "120101")
    end
  end

  it "can create a broadcast attaching an audio file", :js do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_broadcast_path

    select("Voice", from: "Channel")
    attach_file("Audio file", file_fixture("test.mp3"))
    select_filter("Gender", "Equals", select: "Male")
    click_on("Create Broadcast")

    expect(page).to have_content("Broadcast was successfully created.")
    within("#beneficiary_filter_gender") do
      expect(page).to have_field(with: "Gender")
      expect(page).to have_field(with: "Equals")
      expect(page).to have_field(with: "Male")
    end
  end

  it "can update a broadcast", :js do
    account = create(:account, iso_country_code: "KH")
    user = create(:user, account:)
    broadcast = create(
      :broadcast,
      account: user.account,
      beneficiary_filter: {
        disability_status: { eq: 'normal' },
        "address.administrative_division_level_3_code": { in: [ "120101" ] }
      }
    )

    sign_in(user)
    visit edit_dashboard_broadcast_path(broadcast)

    select_filter("Gender", "Equals", select: "Male")
    select_filter("Disability status", "Equals", select: "Disabled", enable_filter: false)
    select_filter("ISO language code", "Equals", fill_in: "khm")

    click_on "Update Broadcast"

    expect(page).to have_text("Broadcast was successfully updated.")
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

  def select_filter(name, operator, **options)
    filter_id = "broadcast_beneficiary_filter_#{name.parameterize.underscore}"

    within("##{filter_id}") do
      if options.fetch(:enable_filter, true)
        check("#{filter_id}_enabled")
      end

      select(operator, from: "#{filter_id}_operator")

      value_input_id = "#{filter_id}_value"
      if options[:select].present?
        select(options.fetch(:select), from: value_input_id)
      elsif options[:fill_in].present?
        fill_in(value_input_id, with: options.fetch(:fill_in))
      end
    end
  end
end
