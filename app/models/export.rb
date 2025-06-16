class Export < ApplicationRecord
  enumerize :resource_type, in: %w[Beneficiary BeneficiaryGroup Broadcast Notification]

  belongs_to :user
  belongs_to :account

  has_one_attached :file

  before_create :set_default_values
  validates :file, presence: true, attached: true, content_type: "text/csv", if: :completed?

  def completed?
    completed_at.present?
  end

  private

  def set_default_values
    self.name ||= format("%s_%s.csv", resource_type.tableize, Time.current.strftime("%Y%m%d%H%M%S"))
  end
end
