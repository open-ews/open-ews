class UpdateBroadcast < ApplicationWorkflow
  class InvalidStateTransitionError < StandardError; end

  attr_reader :broadcast, :desired_status, :params

  def initialize(broadcast, desired_status: nil, **params)
    @broadcast = broadcast
    @desired_status = desired_status
    @params = params
  end

  def call
    broadcast.transaction do
      broadcast.update!(params)
      broadcast.transition_to!(desired_status) if desired_status.present?
    end

    ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast) if broadcast.queued?

    broadcast
  rescue StateMachine::Machine::InvalidStateTransitionError => e
    raise InvalidStateTransitionError, e.message
  end
end
