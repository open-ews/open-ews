require "rails_helper"

RSpec.describe "Locales" do
  let(:user) { create(:user) }

  it "can update the user's preferred language" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    within("#language_menu") do
      click_on("ខែ្មរ")
    end

    expect(page).to have_content("សមាជិកទំនាក់ទំនង")
    expect(page).to have_selector(:xpath, './/html[@lang="km"]')

    user.reload
    expect(user.locale).to eq("km")
  end
end
