require "rails_helper"

RSpec.describe "Imports" do
  it "list imports" do
    user = create(:user, name: "John Doe")
    import = create(:import, :beneficiaries, user:, status: :processing)

    sign_in(user)
    visit dashboard_root_path

    within(".topbar-nav") do
      click_on("John Doe")
      click_on("Profile")
    end
    within(".frame-sidebar") do
      click_on("Imports")
    end

    expect(page).to have_link(import.file.name)
  end
end
