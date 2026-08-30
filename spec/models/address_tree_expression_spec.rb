require "rails_helper"

RSpec.describe AddressTreeExpression do
  describe "#valid?" do
    it "validates the tree" do
      expect(
        AddressTreeExpression.new(
          build_address_filter_data_field(
            operator: :in,
            administrative_level: 3,
            name: :administrative_division_level_3_code,
            value: [ "010201", "010202" ],
            type: "field".inquiry,
          )
        )
      ).to be_valid

      expect(
        AddressTreeExpression.new(
          build_filter_data_group(
            operator: :or,
            conditions: [
              build_filter_data_group(
                operator: :and,
                conditions: [
                  build_address_filter_data_field(
                    operator: :eq,
                    administrative_level: 1,
                    name: :iso_region_code,
                    value: "KH-1",
                  ),
                  build_address_filter_data_field(
                    operator: :eq,
                    administrative_level: 2,
                    name: :administrative_division_level_2_code,
                    value: "0102"
                  ),
                  build_address_filter_data_field(
                    operator: :in,
                    administrative_level: 3,
                    name: :administrative_division_level_3_code,
                    value: [ "010201", "010202" ]
                  )
                ]
              )
            ]
          )
        )
      ).to be_valid

      expect(
        AddressTreeExpression.new(
          build_filter_data_group(
            operator: :and,
            conditions: [
              build_address_filter_data_field(
                operator: :eq,
                administrative_level: 1,
                name: :iso_region_code,
                value: "KH-1",
              ),
              build_address_filter_data_field(
                operator: :eq,
                administrative_level: 1,
                name: :iso_region_code,
                value: "KH-2",
              )
            ]
          )
        )
      ).not_to be_valid
    end
  end

  describe "#to_tree_selection" do
    it "builds a tree selection" do
      filter = build_address_filter_data_field(
        operator: :in,
        administrative_level: 3,
        name: :administrative_division_level_3_code,
        value: [ "010101", "020101", "invalid" ]
      )

      tree = [
        build_address_tree_node(
          id: "KH-1",
          level: 1,
          children: [
            build_address_tree_node(
              id: "0101",
              level: 2,
              children: [
                build_address_tree_node(
                  id: "010101",
                  level: 3,
                  children: []
                ),
                build_address_tree_node(
                  id: "010102",
                  level: 3,
                  children: []
                )
              ]
            ),
            build_address_tree_node(
              id: "0102",
              level: 2,
              children: [
                build_address_tree_node(
                  id: "010201",
                  level: 3,
                  children: []
                ),
              ]
            )
          ],
        ),
        build_address_tree_node(
          id: "KH-2",
          level: 1,
          children: [
            build_address_tree_node(
              id: "0201",
              level: 2,
              children: [
                build_address_tree_node(
                  id: "020101",
                  level: 3,
                  children: []
                )
              ]
            )
          ]
        )
      ]

      tree_expression = AddressTreeExpression.new(filter)
      tree_selection = tree_expression.to_tree_selection(tree)
      expect(tree_selection).to contain_exactly(
        have_attributes(
          id: "KH-1",
          level: 1,
          children: contain_exactly(
            have_attributes(
              id: "0101",
              level: 2,
              children: contain_exactly(
                have_attributes(
                  id: "010101",
                  level: 3,
                  children: be_empty
                )
              )
            )
          )
        ),
        have_attributes(
          id: "KH-2",
          level: 1,
          children: contain_exactly(
            have_attributes(
              id: "0201",
              level: 2,
              children: contain_exactly(
                have_attributes(
                  id: "020101",
                  level: 3,
                  children: be_empty
                )
              )
            )
          )
        )
      )
    end
  end

  def build_address_filter_data_field(administrative_level:, **)
    build_filter_data_field(
      attributes: {
        administrative_level_identifier: true,
        administrative_level:
      },
      **
    )
  end

  def build_filter_data_group(operator:, conditions:)
    build_filter_data_field(
      type: "group".inquiry,
      operator:,
      conditions:
    )
  end

  def build_filter_data_field(**attributes)
    FilterDataType::FilterData::Field.new(
      type: "field".inquiry,
      name: :field_name,
      operator: :eq,
      value: "value",
      attributes: {},
      conditions: [],
      field_definition: nil,
      **attributes
    )
  end

  def build_address_tree_node(**attributes)
    address_tree_node.new(
      id: "KH-1",
      level: 1,
      name: "Battambang",
      children: [],
      **attributes
    )
  end

  def address_tree_node
    Data.define(:id, :level, :name, :children)
  end
end
