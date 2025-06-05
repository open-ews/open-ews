class ImportBeneficiary < ApplicationWorkflow
  attr_reader :import, :data

  def initialize(import:, data:)
    super()
    @import = import
    @data = data.with_indifferent_access
  end

  def call
    marked_for_deletion? ? delete_beneficiary! : create_beneficiary!
  end

  private

  def create_beneficiary!
    raise Errors::ImportError.new(code: :import_contains_marked_for_deletion_flags) if data.key?(:marked_for_deletion)

    beneficiary = Beneficiary.find_or_initialize_by(
      phone_number: data[:phone_number],
      account: import.account
    )
    beneficiary.iso_country_code = sanitize(data.fetch(:iso_country_code)) if data[:iso_country_code].present?
    beneficiary.iso_language_code = sanitize(data.fetch(:iso_language_code)) if data[:iso_language_code].present?
    beneficiary.gender = sanitize(data.fetch(:gender)) if data[:gender].present?
    beneficiary.disability_status = sanitize(data.fetch(:disability_status)) if data[:disability_status].present?
    beneficiary.date_of_birth = sanitize(data.fetch(:date_of_birth)) if data[:date_of_birth].present?
    beneficiary.metadata = extract_metadata(data)

    address_attributes = {
      iso_region_code: sanitize(data[:address_iso_region_code]),
      administrative_division_level_2_code: sanitize(data[:address_administrative_division_level_2_code]),
      administrative_division_level_2_name: sanitize(data[:address_administrative_division_level_2_name]),
      administrative_division_level_3_code: sanitize(data[:address_administrative_division_level_3_code]),
      administrative_division_level_3_name: sanitize(data[:address_administrative_division_level_3_name]),
      administrative_division_level_4_code: sanitize(data[:address_administrative_division_level_4_code]),
      administrative_division_level_4_name: sanitize(data[:address_administrative_division_level_4_name])
    }.compact

    if address_attributes.any?
      raise(Errors::ImportError.new(code: :beneficiary_has_multiple_addresses)) if beneficiary.addresses.many?

      beneficiary.addresses.none? ? beneficiary.addresses.build(address_attributes) : beneficiary.addresses_attributes = { id: beneficiary.addresses.first.id, **address_attributes }
    end

    beneficiary.save!
    beneficiary
  rescue ActiveRecord::RecordInvalid => e
    raise Errors::ImportError.new(e.message, code: :validation_failed)
  end

  def delete_beneficiary!
    beneficiary = Beneficiary.find_by(
      phone_number: data[:phone_number],
      account: import.account
    )

    raise(Errors::ImportError.new(code: :beneficiary_not_found)) if beneficiary.blank?

    DeleteBeneficiary.call(beneficiary)
  end

  def sanitize(data)
    data.to_s.squish.presence
  end

  def marked_for_deletion?
    return if data[:marked_for_deletion].blank?
    raise(Errors::ImportError.new(code: :invalid_marked_for_deletion_flag)) if data.fetch(:marked_for_deletion).downcase != "true"
    raise(Errors::ImportError.new(code: :invalid_import_columns)) if data.keys.difference([ "phone_number", "marked_for_deletion" ]).any?

    true
  end

  def extract_metadata(data)
    data.select { |k, _v| k.start_with?("meta_") }
        .transform_keys { |k| k.delete_prefix("meta_") }
        .transform_values { |v| sanitize(v) }
  end
end
