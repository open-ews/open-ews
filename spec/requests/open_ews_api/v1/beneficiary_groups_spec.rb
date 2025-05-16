require "rails_helper"

RSpec.resource "Beneficiary Groups"  do
  explanation <<~HEREDOC
    The Beneficiary Groups endpoint allows developers to programmatically organize beneficiaries into logical groups for targeted message delivery.
    This is particularly useful when building workflows that require sending notifications to a **specific group** of beneficiaries, such as response teams *in addition to* those matched dynamically by filters.

    Beneficiary Groups are *not* required for sending targeted notifications.
    For most use cases, it's recommended to use [broadcasts with beneficiary filters](#create-and-start-a-broadcast), which dynamically match recipients based on defined criteria.
    Beneficiary Groups, by contrast, are **static collections** of specific beneficiaries.
    They're useful when you need to repeatedly target a fixed set of individuals such as a response team or a predefined community, *in addition to*
    those matched dynamically by filters.

    Through this API, you can create, list, update, and delete groups, as well as manage their relationships with individual beneficiaries.
  HEREDOC

  get "/v1/beneficiary_groups" do
    FieldDefinitions::BeneficiaryGroupFields.each do |field|
      with_options scope: [ :filter, field.name.to_sym ] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    example "List all groups" do
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

    example "Filter groups", document: false do
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
    example "Fetch a group" do
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

    example "Create a group" do
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

    example "Fail to create a group", document: false do
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

    example "Update a group" do
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
    example "Delete a group" do
      account = create(:account)
      group = create(:beneficiary_group, account:)

      set_authorization_header_for(account)
      do_request(id: group.id)

      expect(response_status).to eq(204)
      expect(account.beneficiary_groups).not_to include(group)
    end
  end

  get "/v1/beneficiary_groups/:beneficiary_group_id/members" do
    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :filter, field.name.to_sym] do
        parameter("$operator", field.description, required: false, method: :_disabled)
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

    example "Fail to add a beneficiary to a group", document: false do
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

  get "/v1/beneficiary_groups/:beneficiary_group_id/members/stats" do
    FieldDefinitions::BeneficiaryFields.each do |field|
      with_options scope: [ :filter, field.name.to_sym] do
        parameter("$operator", field.description, required: false, method: :_disabled)
      end
    end

    parameter(
      :group_by,
      "An array of fields to group by. Supported fields: #{V1::BeneficiaryStatsRequestSchema::GROUPS.map { |group| "`#{group}`" }.join(", ")}.",
      required: true
    )

    example "Fetch stats for group members" do
      explanation <<~HEREDOC
        This endpoint provides statistical insights into the beneficiaries within the given group.

        ### Functionality

        This endpoint returns aggregated statistics about the beneficiaries in your group. Common use cases include:

        - Counting the total number of beneficiaries within the group.
        - Grouping beneficiaries by attributes such as location, gender, or address attributes.
        - Identifying trends or patterns in the group.

        ### Parameters

        The endpoint may accept query parameters to filter or group the data. Common parameters include:

        - **Filters:** Specify conditions for narrowing down the results. For example, you might filter beneficiaries by a specific region or status.
        - **Group By:** Group the statistics by a particular attribute such as `gender`, `address`, or `disability_status`.
      HEREDOC

      account = create(:account)
      group = create(:beneficiary_group, account:)
      male_beneficiaries = create_list(:beneficiary, 2, account:, gender: "M")
      male_beneficiaries.each { create(:beneficiary_group_membership, beneficiary: _1, beneficiary_group: group) }
      create(:beneficiary_group_membership, beneficiary_group: group, beneficiary: create(:beneficiary, account:, gender: "F"))
      create(:beneficiary, account:, gender: "F")

      set_authorization_header_for(account)
      do_request(
        beneficiary_group_id: group.id,
        group_by: [ "gender" ]
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("stat", pagination: false)
      results = json_response.fetch("data").map { |data| data.dig("attributes", "result") }
      expect(results).to contain_exactly(
        {
          "gender" => "F",
          "value" => 1
        },
        {
          "gender" => "M",
          "value" => 2
        }
      )
    end
  end
end
