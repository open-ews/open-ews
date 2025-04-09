require "rails_helper"

RSpec.describe "API Key Management" do
  it "can list api keys" do
    user = create(:user)
    sign_in(user)
    access_token = create(:access_token, resource_owner: user.account)
    other_access_token = create(:access_token)

    visit(dashboard_access_tokens_path)

    expect(page).to have_title("API Keys")

    within("#resources") do
      expect(page).to have_content_tag_for(access_token)
      expect(page).not_to have_content_tag_for(other_access_token)
      expect(page).to have_content("API key")
      expect(page).to have_content(access_token.token)
    end
  end
end
