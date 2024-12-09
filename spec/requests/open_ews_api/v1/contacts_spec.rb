require "rails_helper"

RSpec.resource "Contacts"  do
  get "/v1/contacts" do
    example "List all Contacts" do
      account = create(:account)
      account_contact = create(:contact, account:)
      _other_account_contact = create(:contact)

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("contact")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        account_contact.id.to_s
      )
    end
  end

  post "/v1/contacts" do
    example "Create a contact" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :contact,
          attributes: {
            msisdn: "+85510999999",
            language_code: "km",
            gender: "M",
            date_of_birth: "1990-01-01",
            metadata: { "foo" => "bar" }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("contact")
      expect(jsonapi_response_attributes).to include(
        "msisdn" => "+85510999999",
        "language_code" => "km",
        "gender" => "M",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" }
      )
    end

    example "Fail to create a contact", document: false do
      account = create(:account)
      create(:contact, account:, msisdn: "+85510999999")

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :contact,
          attributes: {
            msisdn: "+85510999999"
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "must be unique",
        "source" => { "pointer" => "/data/attributes/msisdn" }
      )
    end
  end

  get "/v1/contacts/:id" do
    example "Get a contact" do
      contact = create(:contact)

      set_authorization_header_for(contact.account)
      do_request(id: contact.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("contact")
      expect(json_response.dig("data", "id")).to eq(contact.id.to_s)
    end
  end

  patch "/v1/contacts/:id" do
    example "Update a contact" do
      contact = create(
        :contact,
        gender: nil,
        language_code: nil,
        date_of_birth: nil,
        metadata: {}
      )

      set_authorization_header_for(contact.account)
      do_request(
        id: contact.id,
        data: {
          id: contact.id,
          type: :contact,
          attributes: {
            gender: "F",
            status: "disabled",
            language_code: "en",
            date_of_birth: "1990-01-01",
            metadata: {
              foo: "bar"
            }
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("contact")
      expect(jsonapi_response_attributes).to include(
        "language_code" => "en",
        "gender" => "F",
        "date_of_birth" => "1990-01-01",
        "metadata" => { "foo" => "bar" }
      )
    end
  end
end
