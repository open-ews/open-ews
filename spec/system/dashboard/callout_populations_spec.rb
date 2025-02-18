require "rails_helper"

RSpec.describe "Callout Populations" do
  it "can list all the callout populations" do
    user = create(:user)
    callout_population = create(
      :callout_population, :preview,
      account: user.account
    )
    other_callout_population = create(
      :callout_population
    )

    sign_in(user)
    visit(dashboard_broadcast_batch_operations_path(callout_population.broadcast))

    within("#page_actions") do
      expect(page).to have_link(
        "New",
        href: new_dashboard_broadcast_batch_operation_callout_population_path(
          callout_population.broadcast
        )
      )
    end

    within("#resources") do
      expect(page).to have_content_tag_for(callout_population)
      expect(page).not_to have_content_tag_for(other_callout_population)
      expect(page).to have_content("#")
      expect(page).to have_link(
        callout_population.id.to_s,
        href: dashboard_batch_operation_path(callout_population)
      )
      expect(page).to have_content("Status")
      expect(page).to have_content("Preview")
    end
  end

  it "create and start callout population", :js do
    user = create(:user)
    broadcast = create(:broadcast, account: user.account)

    sign_in(user)
    visit(new_dashboard_broadcast_batch_operation_callout_population_path(broadcast))

    fill_in_key_values_for(
      :contact_filter_metadata,
      with: {
        "gender" => "f",
        "location:country" => "kh"
      }
    )

    click_on("Create Callout Population")

    expect(page).to have_text("Callout population was successfully created")
    expect(page).to have_content(
      JSON.pretty_generate(
        "gender" => "f",
        "location" => { "country" => "kh" }
      )
    )

    click_on("Start")

    expect(page).to have_content("Event was successfully created.")
    expect(page).not_to have_selector(:link_or_button, "Start")
  end

  it "can update a callout population", :js do
    user = create(:user)
    callout_population = create_callout_population(
      user.account,
      "gender" => "f",
      "location" => {
        "country_code" => "kh"
      }
    )

    sign_in(user)
    visit(
      edit_dashboard_batch_operation_callout_population_path(
        callout_population
      )
    )

    remove_key_value_for(:contact_filter_metadata)
    remove_key_value_for(:contact_filter_metadata)
    add_key_value_for(:contact_filter_metadata)
    fill_in_key_value_for(:contact_filter_metadata, with: { key: "gender", value: "m" })
    click_on "Save"

    expect(page).to have_text("Callout population was successfully updated.")
    expect(callout_population.reload.contact_filter_metadata).to eq("gender" => "m")
  end

  it "can show a callout population" do
    user = create(:user)
    callout_population = create_callout_population(
      user.account,
      location: {
        country: "Cambodia"
      }
    )

    sign_in(user)
    visit(dashboard_batch_operation_path(callout_population))

    within("#page_actions") do
      expect(page).to have_link(
        "Edit",
        href: edit_dashboard_batch_operation_callout_population_path(
          callout_population
        )
      )
    end

    expect(page).to have_content(callout_population.id)
    expect(page).to have_content("Cambodia")
  end

  it "can delete a callout population" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)

    sign_in(user)
    visit dashboard_batch_operation_path(callout_population)

    click_on "Delete"

    expect(page).to have_current_path(
      dashboard_broadcast_batch_operations_path(callout_population.broadcast), ignore_query: true
    )
    expect(page).to have_text("successfully destroyed.")
  end

  it "cannot delete a callout population with callout participations" do
    user = create(:user)
    callout_population = create(:callout_population, account: user.account)
    create(:alert, callout_population:)

    sign_in(user)
    visit dashboard_batch_operation_path(callout_population)

    click_on "Delete"

    expect(page).to have_current_path(
      dashboard_batch_operation_path(callout_population), ignore_query: true
    )
    expect(page).to have_text("could not be destroyed")
  end

  def create_callout_population(account, contact_filter_metadata)
    create(
      :callout_population,
      account:,
      contact_filter_metadata:
    )
  end
end
