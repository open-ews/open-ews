class ExportForm < ApplicationForm
  attribute :user
  attribute :resource_type
  attribute :filter_params

  validates :resource_type, presence: true

  def save!
    export = build_export
    export.save!

    ExecuteWorkflowJob.perform_later(ExportCSV.to_s, export)

    true
  end

  private

  def build_export
    export = user.exports.build(
      resource_type: resource_type,
      account: user.account,
    )
    export.filter_params = normalized_filter_params if filter_params.present?
    export
  end

  def normalized_filter_params
    filter_form = filter_form_class.new(filter_params)
    filter_form.normalized_filter_params
  end

  def filter_form_class
    "#{resource_type}FilterForm".constantize
  end
end
