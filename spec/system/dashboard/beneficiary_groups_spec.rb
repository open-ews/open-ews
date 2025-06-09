require "rails_helper"

RSpec.describe "Beneficiary Groups" do
  it "lists all beneficiary groups" do
    user = create(:user)
    create(:beneficiary_group, name: "My group 1", account: user.account)
    create(:beneficiary_group, name: "My group 2")

    sign_in(user)
    visit dashboard_root_path
    click_on("Beneficiary groups")

    expect(page).to have_title("Beneficiary groups")
    expect(page).to have_content("My group 1")
    expect(page).not_to have_content("My group 2")
  end

  it "lists all members of a group" do
    user = create(:user)
    beneficiary_group = create(:beneficiary_group, name: "My group", account: user.account)
    create(:beneficiary, phone_number: "855715100999", groups: [ beneficiary_group ], account: user.account)

    sign_in(user)
    visit(dashboard_beneficiary_group_path(beneficiary_group))
    click_on("More")
    click_on("Members")

    expect(page).to have_title("Memberships for My group")
    expect(page).to have_link("My group", href: dashboard_beneficiary_group_path(beneficiary_group))
    expect(page).to have_content("+855 71 510 0999")
  end

  it "create a beneficiary group" do
    user = create(:user)

    sign_in(user)
    visit dashboard_beneficiary_groups_path
    click_on "New"

    fill_in("Name", with: "My group")
    click_on("Create Beneficiary group")

    expect(page).to have_text("Beneficiary group was successfully created.")
    expect(page).to have_content("My group")
  end

  it "handles form validations" do
    user = create(:user)

    sign_in(user)
    visit new_dashboard_beneficiary_group_path

    fill_in("Name", with: "")
    click_on("Create Beneficiary group")

    expect(page).to have_text("Name can't be blank")
  end

  it "update a beneficiary group" do
    user = create(:user)
    beneficiary_group = create(:beneficiary_group, name: "My group", account: user.account)

    sign_in(user)
    visit dashboard_beneficiary_group_path(beneficiary_group)
    click_on("Edit")
    fill_in("Name", with: "My new group")
    click_on("Update Beneficiary group")

    expect(page).to have_content("Beneficiary group was successfully updated.")
    expect(page).to have_content("My new group")
  end

  it "delete a beneficiary group" do
    user = create(:user)
    beneficiary_group = create(:beneficiary_group, account: user.account)
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: create(:beneficiary, account: user.account))

    sign_in(user)
    visit dashboard_beneficiary_group_path(beneficiary_group)
    click_on "Delete"

    expect(page).to have_text("Beneficiary group was successfully destroyed.")
  end
end
