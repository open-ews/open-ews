class AddAdministrativeDivisionLevel5CodeAndNameToBeneficiaryAddresses < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column(:beneficiary_addresses, :administrative_division_level_5_code, :citext)
    add_column(:beneficiary_addresses, :administrative_division_level_5_name, :citext)
    add_index(
      :beneficiary_addresses,
      [
        :beneficiary_id,
        :iso_region_code,
        :administrative_division_level_2_code,
        :administrative_division_level_3_code,
        :administrative_division_level_4_code,
        :administrative_division_level_5_code
      ],
      algorithm: :concurrently
    )
    add_index(
      :beneficiary_addresses,
      [
        :beneficiary_id,
        :iso_region_code,
        :administrative_division_level_2_name,
        :administrative_division_level_3_name,
        :administrative_division_level_4_name,
        :administrative_division_level_5_name
      ],
      algorithm: :concurrently
    )

    remove_index(
      :beneficiary_addresses,
      [
        :beneficiary_id,
        :iso_region_code,
        :administrative_division_level_2_code,
        :administrative_division_level_3_code,
        :administrative_division_level_4_code
      ],
      algorithm: :concurrently
    )

    remove_index(
      :beneficiary_addresses,
      [
        :beneficiary_id,
        :iso_region_code,
        :administrative_division_level_2_name,
        :administrative_division_level_3_name,
        :administrative_division_level_4_name
      ],
      algorithm: :concurrently
    )
  end
end
