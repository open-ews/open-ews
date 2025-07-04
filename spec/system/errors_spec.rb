require "rails_helper"

RSpec.describe "Errors", type: :system do
  it "renders the error page" do
    visit "/500"

    expect(page).to have_content("The server encountered an internal error.")
    expect(page).to have_link("Take me home", href: dashboard_root_path)
  end
end
