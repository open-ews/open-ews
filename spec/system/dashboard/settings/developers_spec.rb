require "rails_helper"

RSpec.describe "Developer Settings" do
  it "can view the developer settings" do
    account = create(:account)
    create(:access_token, account:)
    user = create(:user, account:)

    account_sign_in(user)
    visit(dashboard_settings_developer_path)

    expect(page).to have_field("API key", with: account.api_key)
  end
end
