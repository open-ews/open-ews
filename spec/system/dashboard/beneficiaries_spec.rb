require "rails_helper"

RSpec.describe "Beneficiaries" do
  it "lists all beneficiaries" do
    user = create(:user)
    _beneficiary = create(:beneficiary, phone_number: "85516789111", account: user.account)
    _other_beneficiary = create(:beneficiary, phone_number: "85510555123")

    sign_in(user)
    visit dashboard_beneficiaries_path

    expect(page).to have_title("Beneficiaries")
    expect(page).to have_content("85516789111")
    expect(page).not_to have_content("85510555123")
  end

  it "imports beneficiaries" do
    user = create(:user)

    sign_in(user)
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

  it "creates a new beneficiary", :js do
    user = create(:user)

    sign_in(user)
    visit dashboard_beneficiaries_path
    click_on "New"

    fill_in("Phone number", with: "85516789111")
    select("Cambodia", from: "Country")
    click_on("Add Address")
    fill_in("ISO region code", with: "KH-12")
    click_on "Create Beneficiary"

    expect(page).to have_title(/Beneficiary/)
    expect(page).to have_content("Beneficiary was successfully created.")
    expect(page).to have_content("85516789111")
    expect(page).to have_content("KH-12")
  end

  it "fail to create a new beneficiary", :js do
    user = create(:user)
    create(:beneficiary, phone_number: "85516789111", account: user.account)

    sign_in(user)
    visit new_dashboard_beneficiary_path
    fill_in "Phone number", with: "85516789111"
    select "Cambodia", from: "Country"
    click_on "Create Beneficiary"

    expect(page).to have_text("Phone number has already been taken")
  end

  it "delete a beneficiary" do
    user = create(:user)
    beneficiary = create(:beneficiary, account: user.account)

    sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)
    click_on "Delete"

    expect(page).to have_text("Beneficiary was successfully destroyed.")
  end

  it "update a beneficiary", :js do
    user = create(:user)
    beneficiary = create(
      :beneficiary,
      gender: "M",
      account: user.account,
      phone_number: "85516789111",
    )

    sign_in(user)
    visit dashboard_beneficiary_path(beneficiary)
    click_on("Edit")
    fill_in("Phone number", with: "85516789111")
    select("Female", from: "Gender")
    fill_in("ISO language code", with: "khm")
    click_on("Add Address")
    fill_in("ISO region code", with: "KH-12")
    click_on("Update Beneficiary")

    expect(page).to have_content("Beneficiary was successfully updated.")
    expect(page).to have_content("85516789111")
    expect(page).to have_content("Female")
    expect(page).to have_content("khm")
    expect(page).to have_content("KH-12")
  end
end
