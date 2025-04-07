require "rails_helper"

RSpec.describe "Account Settings" do
  it "can update the account settings", :js do
    user = create(:user)
    sign_in(user)

    visit(edit_dashboard_account_path)

    expect(page).to have_title("Account Settings")

    somleng_account_sid = generate(:somleng_account_sid)
    somleng_auth_token = generate(:auth_token)

    fill_in("Somleng account sid", with: somleng_account_sid)
    fill_in("Somleng auth token", with: somleng_auth_token)

    click_on("Save")

    expect(page).to have_current_path(edit_dashboard_account_path, ignore_query: true)
    expect(page).to have_text("Account was successfully updated.")
    user.account.reload
    expect(user.account.somleng_account_sid).to eq(somleng_account_sid)
    expect(user.account.somleng_auth_token).to eq(somleng_auth_token)
  end
end
