class Export < ApplicationRecord
  class StateMachine < StateMachine::ActiveRecord
    state :processing, initial: true, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :completed
  end

  delegate :transition_to!, to: :state_machine
  enumerize :resource_type, in: %w[Beneficiary BeneficiaryGroup Broadcast Notification]
  enumerize :status, in: StateMachine.state_definitions.map(&:name)

  belongs_to :user
  belongs_to :account

  has_one_attached :file

  delegate :completed?, to: :state_machine

  before_create :set_default_values
  validates :file, presence: true, attached: true, content_type: "text/csv", if: :completed?

  private

  def state_machine
    StateMachine.new(self)
  end

  def set_default_values
    self.status ||= state_machine.current_state.name
    self.name ||= format("%s_%s.csv", resource_type.tableize, Time.current.strftime("%Y%m%d%H%M%S"))
  end
end
