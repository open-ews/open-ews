require "rails_helper"

RSpec.describe "Callout Participations" do
  it "can list all callout participations for an account" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)
    running_callout_participation = create_callout_participation(
      account: user.account, callout: create(:callout, :running, account: user.account)
    )
    other_callout_participation = create(:callout_participation)

    sign_in(user)
    visit(
      dashboard_callout_participations_path(
        q: { callout_filter_params: { status: :initialized } }
      )
    )

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(callout_participation)
      expect(page).not_to have_content_tag_for(other_callout_participation)
      expect(page).not_to have_content_tag_for(running_callout_participation)
      expect(page).to have_content("#")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Callout")
      expect(page).to have_link(
        callout_participation.id.to_s,
        href: dashboard_callout_participation_path(callout_participation)
      )
      expect(page).to have_link(
        callout_participation.contact_id.to_s,
        href: dashboard_contact_path(callout_participation.contact)
      )
      expect(page).to have_link(
        callout_participation.callout_id.to_s,
        href: dashboard_callout_path(callout_participation.callout)
      )
      expect(page).to have_sortable_column("created_at")
    end
  end

  it "can list all callout participations for a callout" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)
    other_callout_participation = create_callout_participation(account: user.account)

    sign_in(user)
    visit(dashboard_callout_callout_participations_path(callout_participation.callout))

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(callout_participation)
      expect(page).not_to have_content_tag_for(other_callout_participation)
    end
  end

  it "can list all the callout participations for a contact" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)
    other_callout_participation = create_callout_participation(account: user.account)

    sign_in(user)
    visit(dashboard_contact_callout_participations_path(callout_participation.contact))

    expect(page).to have_title("Callout Participations")

    within("#resources") do
      expect(page).to have_content_tag_for(callout_participation)
      expect(page).not_to have_content_tag_for(other_callout_participation)
    end
  end

  it "can show a callout participation" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    callout_participation = create_callout_participation(
      account: user.account,
      callout: callout_population.callout,
      callout_population:
    )

    sign_in(user)
    visit(dashboard_callout_participation_path(callout_participation))

    expect(page).to have_title("Callout Participation #{callout_participation.id}")

    within("#related_links") do
      expect(page).to have_link(
        "Phone Calls",
        href: dashboard_callout_participation_phone_calls_path(callout_participation)
      )
    end

    within(".callout_participation") do
      expect(page).to have_content(callout_participation.id)

      expect(page).to have_link(
        callout_participation.callout_id.to_s,
        href: dashboard_callout_path(callout_participation.callout)
      )

      expect(page).to have_link(
        callout_participation.contact_id.to_s,
        href: dashboard_contact_path(callout_participation.contact)
      )

      expect(page).to have_link(
        callout_participation.callout_population_id.to_s,
        href: dashboard_batch_operation_path(callout_participation.callout_population)
      )

      expect(page).to have_content("Callout")
      expect(page).to have_content("Contact")
      expect(page).to have_content("Callout population")
      expect(page).to have_content("Created at")
    end
  end

  it "can delete a callout participation" do
    user = create(:user)
    callout_participation = create_callout_participation(account: user.account)

    sign_in(user)
    visit dashboard_callout_participation_path(callout_participation)

    click_on "Delete"

    expect(page).to have_current_path(dashboard_callout_participations_path, ignore_query: true)
    expect(page).to have_text("was successfully destroyed")
  end
end
