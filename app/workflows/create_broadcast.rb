class CreateBroadcast < ApplicationWorkflow
  attr_reader :scope, :desired_status, :params

  def initialize(scope, desired_status: nil, **params)
    @scope = scope
    @desired_status = desired_status
    @params = params
  end

  def call
    Broadcast.transaction do
      broadcast = scope.create!(params)
      broadcast.transition_to!(desired_status) if desired_status.present?
      ExecuteWorkflowJob.perform_later(StartBroadcast.to_s, broadcast) if broadcast.queued?
      broadcast
    end
  end
end
