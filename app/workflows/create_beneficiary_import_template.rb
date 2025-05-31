require "csv"

class CreateBeneficiaryImportTemplate < ApplicationWorkflow
  attr_reader :template, :fields

  def initialize(**options)
    super()
    @template = options.fetch(:template, Pathname(Rails.root.join("app", "assets", "files", "beneficiary_import_template.csv")))
    @fields = options.fetch(:fields) { FieldDefinitions::BeneficiaryFields.select { |field| !field.read_only? } }
  end

  def call
    CSV.open(template, "w") do |csv|
      csv << attribute_names
      csv << sample_data
    end
  end

  private

  def attribute_names
    ordered_fields.map { |field| field.path.to_s.parameterize.underscore }
  end

  def sample_data
    fields.map(&:example).compact
  end

  def ordered_fields
    fields.sort_by { |field| field.required? ? 0 : 1 }
  end
end
