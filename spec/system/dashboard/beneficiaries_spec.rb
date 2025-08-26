require "rails_helper"

RSpec.describe "Beneficiaries" do
  it "lists all beneficiaries", :js do
    user = create(:user)
    _active_beneficiary = create(:beneficiary, phone_number: "85516789111", status: :active, account: user.account)
    _disabled_beneficiary = create(:beneficiary, phone_number: "85510888888", status: :disabled, account: user.account)
    _other_beneficiary = create(:beneficiary, phone_number: "85510555123")

    account_sign_in(user)
    visit dashboard_beneficiaries_path

    expect(page).to have_title("Beneficiaries")
    expect(page).to have_content("+855 16 789 111")
    expect(page).to have_content("+855 10 888 888")
    expect(page).not_to have_content("+855 10 555 123")

    click_on "Filters"
    select_filter("Status", operator: "Equals", select: "Active")
    click_on "Apply Filters"

    expect(page).to have_content("+855 16 789 111")
    expect(page).not_to have_content("+855 10 888 888")
    expect(page).not_to have_content("+855 10 555 123")
  end

  it "imports beneficiaries" do
    user = create(:user)

    account_sign_in(user)
    visit dashboard_beneficiaries_path
    click_on("Import")
    attach_file("File", file_fixture("beneficiaries.csv"))
    perform_enqueued_jobs do
      click_on("Upload")
    end

    within(".alert") do
      expect(page).to have_content("Your import is being processed")
      click_on("Imports")
    end

    expect(page).to have_content("Succeeded")
    expect(page).to have_content("beneficiaries.csv")
  end

  it "fails to import beneficiaries" do
    user = create(:user)

    account_sign_in(user)
    visit dashboard_beneficiaries_path
    click_on("Import")
    attach_file("File", file_fixture("test.mp3"))
    click_on("Upload")

    expect(page).to have_content("Failed to create import: File has an invalid content type (authorized content type is CSV)")
  end

  it "creates a new beneficiary", :js do
    user = create(:user)
    create(:beneficiary_group, name: "My group", account: user.account)
    create(:beneficiary_group, name: "My other group", account: user.account)

    account_sign_in(user)
    visit dashboard_beneficiaries_path
    click_on "New"

    fill_in("Phone number", with: "85516789111")
    select("Cambodia", from: "Country")
    select_list("My group", "My other group", from: "Groups")
    click_on("Add Address")
    fill_in("ISO region code", with: "KH-12")

    click_on "Create Beneficiary"

    expect(page).to have_content("Beneficiary was successfully created.")
    expect(page).to have_title("Beneficiary")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    expect(page).to have_content("+855 16 789 111")
    expect(page).to have_content("KH-12")
  end

  it "fail to create a new beneficiary", :js do
    user = create(:user)
    create(:beneficiary, phone_number: "85516789111", account: user.account)

    account_sign_in(user)
    visit new_dashboard_beneficiary_path
    fill_in "Phone number", with: "85516789111"
    select "Cambodia", from: "Country"
    click_on "Create Beneficiary"

    expect(page).to have_text("Phone number has already been taken")
  end

  it "show a beneficiary" do
    user = create(:user)
    beneficiary = create(
      :beneficiary,
      iso_country_code: "KH",
      account: user.account,
      metadata: {
        baz: 123,
        foo: "bar"
      }
    )
    create(
      :beneficiary_address,
      beneficiary:,
      iso_region_code: "KH-12",
      administrative_division_level_2_code: "1202",
      administrative_division_level_2_name: "Doun Penh"
    )

    account_sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)

    expect(page).to have_content("KH-12")
    expect(page).to have_content("1202")
    expect(page).to have_content("Doun Penh")
    expect(page).to have_field(with: JSON.pretty_generate(beneficiary.metadata))
  end

  it "delete a beneficiary" do
    user = create(:user)
    beneficiary = create(:beneficiary, account: user.account)

    account_sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)
    click_on "Delete"

    expect(page).to have_text("Beneficiary was successfully destroyed.")
  end

  it "update a beneficiary", :js do
    user = create(:user)
    create(:beneficiary_group, name: "My other group", account: user.account)
    beneficiary = create(
      :beneficiary,
      gender: "M",
      account: user.account,
      phone_number: "85516789111",
      groups: [ create(:beneficiary_group, name: "My group", account: user.account) ]
    )

    account_sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)
    click_on("Edit")
    fill_in("Phone number", with: "85516789111")
    select("Female", from: "Gender")
    fill_in("ISO language code", with: "khm")
    select_list("My other group", from: "Groups")
    click_on("Add Address")
    fill_in("ISO region code", with: "KH-12")
    click_on("Update Beneficiary")

    expect(page).to have_content("Beneficiary was successfully updated.")
    expect(page).to have_content("+855 16 789 111")
    expect(page).to have_content("My group")
    expect(page).to have_content("My other group")
    expect(page).to have_content("Female")
    expect(page).to have_content("khm")
    expect(page).to have_content("KH-12")
  end
end
