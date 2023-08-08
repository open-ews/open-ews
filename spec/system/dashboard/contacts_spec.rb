require "rails_helper"

RSpec.describe "Contacts", :aggregate_failures do
  it "can list all contacts" do
    user = create(:user)
    contact = create(:contact, account: user.account)
    other_contact = create(:contact)

    sign_in(user)
    visit dashboard_contacts_path

    expect(page).to have_title("Contacts")

    within("#page_actions") do
      expect(page).to have_link("New", href: new_dashboard_contact_path)
    end

    within("#resources") do
      expect(page).to have_content_tag_for(contact)
      expect(page).not_to have_content_tag_for(other_contact)
      expect(page).to have_content("#")
      expect(page).to have_link(
        contact.id.to_s,
        href: dashboard_contact_path(contact)
      )

      expect(page).to have_sortable_column("msisdn")
      expect(page).to have_sortable_column("created_at")
    end
  end

  it "can create a new contact" do
    user = create(:user)
    phone_number = generate(:somali_msisdn)

    sign_in(user)
    visit new_dashboard_contact_path

    expect(page).to have_title("New Contact")

    click_action_button(:create, key: :submit, namespace: :helpers, model: "Contact")

    expect(page).to have_content("Phone number must be filled")

    fill_in("Phone number", with: phone_number)
    fill_in_key_value_for(:metadata, with: { key: "name", value: "Bob Chann" })
    click_action_button(:create, key: :submit, namespace: :helpers, model: "Contact")

    expect(page).to have_text("Contact was successfully created.")
    new_contact = user.reload.account.contacts.last!
    expect(new_contact.msisdn).to match(phone_number)
    expect(new_contact.metadata).to eq("name" => "Bob Chann")
  end

  it "can update a contact", :js do
    user = create(:user)
    contact = create(
      :contact,
      account: user.account,
      metadata: {
        "location" => { "country" => "kh", "city" => "Phnom Penh" }
      }
    )

    sign_in(user)
    visit edit_dashboard_contact_path(contact)

    expect(page).to have_title("Edit Contact")

    updated_phone_number = generate(:somali_msisdn)
    fill_in("Phone number", with: updated_phone_number)
    remove_key_value_for(:metadata)
    remove_key_value_for(:metadata)
    add_key_value_for(:metadata)
    fill_in_key_value_for(:metadata, with: { key: "gender", value: "f" })
    click_action_button(:update, key: :submit, namespace: :helpers)

    expect(page).to have_current_path(dashboard_contact_path(contact))
    expect(page).to have_text("Contact was successfully updated.")
    expect(contact.reload.msisdn).to match(updated_phone_number)
    expect(contact.metadata).to eq("gender" => "f")
  end

  it "can delete a contact" do
    user = create(:user)
    contact = create(:contact, account: user.account)

    sign_in(user)
    visit dashboard_contact_path(contact)

    click_on "Delete"

    expect(current_path).to eq(dashboard_contacts_path)
    expect(page).to have_text("Contact was successfully destroyed.")
  end

  it "can show a contact" do
    user = create(:user)
    phone_number = generate(:somali_msisdn)
    contact = create(
      :contact,
      account: user.account,
      msisdn: phone_number,
      metadata: { "location" => { "country" => "Cambodia" } }
    )

    sign_in(user)
    visit dashboard_contact_path(contact)

    expect(page).to have_title("Contact #{contact.id}")

    within("#page_actions") do
      expect(page).to have_link_to_action(
        :edit,
        href: edit_dashboard_contact_path(contact)
      )
    end

    within("#related_links") do
      expect(page).to have_link_to_action(
        :index,
        key: :callout_participations,
        href: dashboard_contact_callout_participations_path(contact)
      )

      expect(page).to have_link_to_action(
        :index,
        key: :phone_calls,
        href: dashboard_contact_phone_calls_path(contact)
      )
    end

    within(".contact") do
      expect(page).to have_content(contact.id)
      expect(page).to have_content("Cambodia")
    end
  end
end
