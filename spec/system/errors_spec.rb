require "rails_helper"

RSpec.describe "Errors", type: :system do
  it "renders the error page" do
    visit "/500"

    expect(page).to have_content("The server encountered an internal error.")
    expect(page).to have_link("Take me home", href: dashboard_root_path)
  end

  it "renders the outdated browser page" do
    page.driver.browser.header("User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)")

    visit dashboard_root_path

    expect(page).to have_content("Your browser is not supported.")
  end
end
