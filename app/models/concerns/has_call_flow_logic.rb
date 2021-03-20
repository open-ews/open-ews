module HasCallFlowLogic
  extend ActiveSupport::Concern

  included do
    validates :call_flow_logic, presence: true, call_flow_logic: true
  end

  def call_flow_logic=(value)
    self[:call_flow_logic] = value.presence
  end
end
