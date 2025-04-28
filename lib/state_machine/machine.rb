module StateMachine
  class Machine
    class InvalidStateTransitionError < StandardError; end

    attr_reader :current_state

    StateDefinition = Data.define(:name, :transitions_to, :initial)
    Transition = Data.define(:name, :as)

    class << self
      def find(state)
        state_definitions.find(-> { state_definitions.find(&:initial) || raise(ArgumentError("Unknown state #{state}")) }) { _1.name == state.to_s.to_sym }
      end

      def state(name, **options)
        state_definitions << StateDefinition.new(
          name:,
          transitions_to: Array(options.fetch(:transitions_to, [])).map do |(name, options)|
            Transition.new(name:, as: (options || {}).fetch(:as, nil))
          end,
          initial: options.fetch(:initial, false)
        )
        define_method("#{name}?", -> { current_state.name == name })
      end

      def state_definitions
        @state_definitions ||= []
      end
    end

    def initialize(current_state = nil)
      @current_state = self.class.find(current_state)
    end

    def transition_to(new_state)
      @current_state = if may_transition_to?(new_state)
        transition = find_transition(new_state)
        self.class.find(transition.as || transition.name)
      else
        current_state
      end
    end

    def transition_to!(new_state)
      may_transition_to?(new_state) ? transition_to(new_state) : raise(InvalidStateTransitionError.new("Cannot transition from #{current_state.name} to #{new_state}"))
    end

    def may_transition_to?(new_state)
      find_transition(new_state).present?
    end

    private

    def find_transition(new_state)
      current_state.transitions_to.find { _1.name == new_state.to_s.to_sym }
    end
  end
end
