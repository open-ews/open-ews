class BroadcastStatusValidator
  attr_reader :broadcast

  delegate :may_transition_to?, :transition_to!, to: :state_machine

  class StateMachine < StateMachine::Machine
    state :pending, transitions_to: { running: { as: :queued } }
    state :queued
    state :errored, transitions_to: { running: { as: :queued } }
    state :running, transitions_to: :stopped
    state :stopped, transitions_to: :running
    state :completed
  end

  def initialize(broadcast)
    @broadcast = broadcast
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(broadcast.status)
  end
end
