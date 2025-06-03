require "rails_helper"

RSpec.describe "Locales" do
  it "can update the user's preferred language" do
    user = create(:user, locale: "km")

    sign_in(user)
    visit dashboard_root_path

    expect(page.find("html")[:lang]).to eq("km")

    click_on("English")

    expect(page.find("html")[:lang]).to eq("en")
  end
end
