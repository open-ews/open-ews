class ImportBeneficiary < ApplicationWorkflow
  attr_reader :import, :data

  class Error < Errors::ImportError; end

  def initialize(import:, data:)
    @import = import
    @data = data.with_indifferent_access
  end

  def call
    marked_for_deletion? ? delete_beneficiary! : create_beneficiary!
  end

  private

  def create_beneficiary!
    raise Error.new("Cannot create beneficiaries when import contains 'marked_for_deletion' flags. Remove the 'marked_for_deletion' column and try again") if data.key?(:marked_for_deletion)

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
      iso_region_code: sanitize(data[:"address_iso_region_code"]),
      administrative_division_level_2_code: sanitize(data[:"address_administrative_division_level_2_code"]),
      administrative_division_level_2_name: sanitize(data[:"address_administrative_division_level_2_name"]),
      administrative_division_level_3_code: sanitize(data[:"address_administrative_division_level_3_code"]),
      administrative_division_level_3_name: sanitize(data[:"address_administrative_division_level_3_name"]),
      administrative_division_level_4_code: sanitize(data[:"address_administrative_division_level_4_code"]),
      administrative_division_level_4_name: sanitize(data[:"address_administrative_division_level_4_name"])
    }.compact

    if address_attributes.any?
      raise Error.new("Beneficiary has multiple addresses") if beneficiary.addresses.many?

      beneficiary.addresses.none? ? beneficiary.addresses.build(address_attributes) : beneficiary.addresses_attributes = { id: beneficiary.addresses.first.id, **address_attributes }
    end

    beneficiary.save!
    beneficiary
  rescue ActiveRecord::RecordInvalid => e
    raise Error.new(e)
  end

  def delete_beneficiary!
    beneficiary = Beneficiary.find_by(
      phone_number: data[:phone_number],
      account: import.account
    )

    raise Error.new("Cannot find phone number") if beneficiary.blank?

    DeleteBeneficiary.call(beneficiary)
  end

  def sanitize(data)
    data.to_s.squish.presence
  end

  def marked_for_deletion?
    return if data[:marked_for_deletion].blank?
    raise Error.new("'marked_for_deletion' must be set to true'") if data.fetch(:marked_for_deletion).downcase != "true"
    raise Error.new("must contain only 'phone_number' and 'marked_for_deletion'") if data.keys.difference([ "phone_number", "marked_for_deletion" ]).any?

    true
  end

  def extract_metadata(data)
    data.select { |k, _v| k.start_with?("meta_") }
        .transform_keys { |k| k.delete_prefix("meta_") }
        .transform_values { |v| sanitize(v) }
  end
end
