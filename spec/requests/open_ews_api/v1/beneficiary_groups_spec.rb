require "rails_helper"

RSpec.resource "Beneficiary Groups"  do
  get "/v1/beneficiary_groups" do
    with_options scope: :filter do
      FieldDefinitions::BeneficiaryGroupFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "List all beneficiary groups" do
      account = create(:account)
      group = create(:beneficiary_group, account:, name: "My Group")
      other_group = create(:beneficiary_group, account:, name: "Other Group")
      create(:beneficiary_group, name: "My Group")

      set_authorization_header_for(account)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary_group")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        group.id.to_s,
        other_group.id.to_s
      )
    end

    example "Filter a beneficiary group", document: false do
      account = create(:account)
      group = create(:beneficiary_group, account:, name: "My Group")
      create(:beneficiary_group, account:, name: "Other Group")

      set_authorization_header_for(account)
      do_request(filter: { name: { eq: "My Group" } })

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary_group")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        group.id.to_s
      )
    end
  end

  get "/v1/beneficiary_groups/:id" do
    example "Fetch a beneficiary group" do
      group = create(:beneficiary_group)

      set_authorization_header_for(group.account)
      do_request(id: group.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary_group")
      expect(json_response.dig("data", "id")).to eq(group.id.to_s)
    end
  end

  post "/v1/beneficiary_groups" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `beneficiary_group`",
        required: true,
        method: :_disabled
      )
    end
    with_options scope: %i[data attributes] do
      parameter(
        :name, "A friendly name for the group.",
        required: true,
        method: :_disabled
      )
    end

    example "Create a beneficiary group" do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary_group,
          attributes: {
            name: "My Group"
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary_group")
      expect(jsonapi_response_attributes).to include(
        "name" => "My Group"
      )
    end

    example "Fail to create a beneficiary group", document: false do
      account = create(:account)

      set_authorization_header_for(account)
      do_request(
        data: {
          type: :beneficiary_group,
          attributes: {
            name: nil
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "must be filled",
        "source" => { "pointer" => "/data/attributes/name" }
      )
    end
  end

  patch "/v1/beneficiary_groups/:id" do
    with_options scope: %i[data] do
      parameter(
        :id, "The unique identifier of the beneficiary_group.",
        required: true,
        method: :_disabled
      )
      parameter(
        :type, "Must be `beneficiary_group`",
        required: true,
        method: :_disabled
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :name, "A friendly name for the group.",
        required: true,
        method: :_disabled
      )
    end

    example "Update a beneficiary group" do
      group = create(:beneficiary_group)

      set_authorization_header_for(group.account)
      do_request(
        id: group.id,
        data: {
          id: group.id,
          type: :beneficiary_group,
          attributes: {
            name: "VIP Group"
          }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary_group")
      expect(jsonapi_response_attributes).to include(
        "name" => "VIP Group"
      )
    end
  end

  delete "/v1/beneficiary_groups/:id" do
    example "Delete a beneficiary" do
      account = create(:account)
      group = create(:beneficiary_group, account:)

      set_authorization_header_for(account)
      do_request(id: group.id)

      expect(response_status).to eq(204)
      expect(account.beneficiary_groups).not_to include(group)
    end
  end

  get "/v1/beneficiary_groups/:beneficiary_group_id/members" do
    with_options scope: :filter do
      FieldDefinitions::BeneficiaryFields.each do |field|
        parameter(field.name, field.description, required: false, method: :_disabled)
      end
    end

    example "List all members of a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary, account:)
      other_beneficiary = create(:beneficiary, account:)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary:)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary: other_beneficiary)
      create(:beneficiary_group_membership, beneficiary_group: create(:beneficiary_group, account:))

      set_authorization_header_for(account)
      do_request(beneficiary_group_id: group.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        beneficiary.id.to_s,
        other_beneficiary.id.to_s
      )
    end

    example "Filter members of a group", document: false do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary, account:, gender: "M")
      other_beneficiary = create(:beneficiary, account:, gender: "F")
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary:)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary: other_beneficiary)

      set_authorization_header_for(account)
      do_request(
        beneficiary_group_id: group.id,
        filter: {
          gender: { eq: "M" }
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("beneficiary")
      expect(json_response.fetch("data").pluck("id")).to contain_exactly(
        beneficiary.id.to_s
      )
    end
  end

  get "/v1/beneficiary_groups/:beneficiary_group_id/members/:id" do
    example "Fetch a member of a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary:)

      set_authorization_header_for(group.account)
      do_request(
        beneficiary_group_id: group.id,
        id: beneficiary.id
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "id")).to eq(beneficiary.id.to_s)
    end
  end

  post "/v1/beneficiary_groups/:beneficiary_group_id/members" do
    with_options scope: %i[data] do
      parameter(
        :type, "Must be `beneficiary_group_member`",
        required: true,
        method: :_disabled
      )
    end

    with_options scope: %i[data attributes] do
      parameter(
        :beneficiary_id, "The unique identifier of the `beneficiary`",
        required: true,
        method: :_disabled
      )
    end

    example "Add a beneficiary to a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary, account:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_group_id: group.id,
        data: {
          type: :beneficiary_group_member,
          attributes: {
            beneficiary_id: beneficiary.id
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_jsonapi_resource_schema("beneficiary")
      expect(json_response.dig("data", "id")).to eq(beneficiary.id.to_s)
    end

    example "Fail to add a beneficiary to a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_group_id: group.id,
        data: {
          type: :beneficiary_group_member,
          attributes: {
            beneficiary_id: beneficiary.id
          }
        }
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("jsonapi_error")
      expect(json_response.dig("errors", 0)).to include(
        "title" => "is invalid",
        "source" => { "pointer" => "/data/attributes/beneficiary_id" }
      )
    end
  end

  delete "/v1/beneficiary_groups/:beneficiary_group_id/members/:id" do
    example "Remove a beneficiary from a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)
      beneficiary = create(:beneficiary, account:)
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary:)

      set_authorization_header_for(account)
      do_request(
        beneficiary_group_id: group.id,
        id: beneficiary.id
      )

      expect(response_status).to eq(204)
      expect(account.beneficiaries).to include(beneficiary)
      expect(group.members).not_to include(beneficiary)
    end
  end
end
