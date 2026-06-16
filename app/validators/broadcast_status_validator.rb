class BroadcastStatusValidator
  attr_reader :errors, :state_machine, :routing_rules

  Error = Data.define(:key, :message)

  def initialize(**options)
    @errors = []
    @state_machine = options.fetch(:state_machine) { BroadcastStateMachine.new }
    @routing_rules = options.fetch(:routing_rules) { BroadcastRoutingRules.new }
  end

  def valid?(**attributes)
    next unless broadcast_state_machine.may_transition_to?(attributes[:status])
    next unless BroadcastRoutingRules.new(attributes[:channel]).deliverable?
    next if account.configured_for_broadcasts?

    base.failure("Account not configured")
  end
end
