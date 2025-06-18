class ExportForm < ApplicationForm
  class InvalidFormValues < StandardError; end

  NESTED_RESOURCE_TYPES = {
    "Notification" => {
      scope_model: Broadcast,
      field: :broadcast_id
    },
    "BeneficiaryGroupMembership" => {
      scope_model: BeneficiaryGroup,
      field: :beneficiary_group_id
    }
  }.freeze

  attribute :user
  attribute :resource_type
  attribute :scoped_id
  attribute :filter_params

  validates :resource_type, presence: true, inclusion: { in: Export.resource_type.values }
  validate :validate_scoped_id

  delegate :account, to: :user

  def save!
    raise InvalidFormValues if invalid?

    export = build_export
    export.save!

    ExecuteWorkflowJob.perform_later(ExportCSV.to_s, export)

    true
  end

  private

  attr_accessor :scoped_to

  def build_export
    export = user.exports.build(
      resource_type: resource_type,
      account: user.account,
      scoped_to: scoped_to
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

  def validate_scoped_id
    if NESTED_RESOURCE_TYPES.key?(resource_type)
      scope = NESTED_RESOURCE_TYPES[resource_type]
      scoped_field = scope.fetch(:field)
      scope_model = scope.fetch(:scope_model)

      if scope_model.where(account: account, id: scoped_id).none?
        errors.add(:scoped_id, "is not valid")
      end

      self.scoped_to = { scoped_field => scoped_id }
    else
      self.scoped_to = { account_id: account.id }
    end
  end

  def resources_scope
    resource_type.constantize
  end
end
