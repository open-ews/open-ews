require "rails_helper"

RSpec.describe "Locales" do
  it "can update the user's preferred language" do
    user = create(:user)

    sign_in(user)
    visit dashboard_root_path

    click_on("ខែ្មរ")

    expect(page).to have_content("សេចក្ដីប្រកាស")
    expect(page).to have_selector(:xpath, './/html[@lang="km"]')
  end
end
