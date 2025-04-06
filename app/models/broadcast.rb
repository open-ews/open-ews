class Broadcast < ApplicationRecord
  extend Enumerize

  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/x-wav].freeze
  CHANNELS = %i[voice].freeze

  include MetadataHelpers

  class StateMachine < StateMachine::ActiveRecord
    state :pending, initial: true, transitions_to: [ :errored, :queued ]
    state :errored, transitions_to: [ :running ]
    state :queued, transitions_to: [ :running ]
    state :running, transitions_to: [ :stopped, :completed ]
    state :stopped, transitions_to: [ :running, :completed ]
    state :completed
  end

  store_accessor :settings
  accepts_nested_key_value_fields_for :settings

  # TODO: Remove the default after we removed the old API
  enumerize :channel, in: CHANNELS, default: :voice

  belongs_to :account
  belongs_to :created_by, class_name: "User", optional: true

  has_many :alerts, dependent: :restrict_with_error
  has_many :beneficiaries, through: :alerts

  has_many :batch_operations,
           class_name: "BatchOperation::Base",
           dependent: :restrict_with_error

  has_many :callout_populations,
           class_name: "BatchOperation::CalloutPopulation"
  has_many :populations,
           class_name: "BatchOperation::CalloutPopulation"

  has_many :delivery_attempts
  has_many :remote_phone_call_events, through: :delivery_attempts

  has_one_attached :audio_file

  validates :channel, :status, presence: true

  validates :audio_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: AUDIO_CONTENT_TYPES
            },
            if: ->(callout) { callout.audio_file.attached? }

  delegate :call_flow_logic,
           to: :account,
           prefix: true,
           allow_nil: true

  aasm column: :status, whiny_transitions: false do
    state :pending, initial: true
    state :errored
    state :queued
    state :running
    state :stopped
    state :completed

    event :error do
      transitions(
        from: [ :pending, :queued ],
        to: :errored
      )
    end

    # TODO: Remove state transition from pending after we removed the old API
    event :start do
      transitions(
        from: [ :pending, :queued, :errored ],
        to: :running,
        before_transaction: -> { self.error_message = nil }
      )
    end

    event :stop do
      transitions(
        from: [ :running, :queued ],
        to: :stopped
      )
    end

    # TODO: Remove the pause event after we removed the old API
    event :pause do
      transitions(
        from: [ :running, :queued ],
        to: :stopped
      )
    end

    event :resume do
      transitions(
        from: :stopped,
        to: :running
      )
    end

    event :complete do
      transitions(
        from: :running,
        to: :completed
      )
    end
  end

  def self.jsonapi_serializer_class
    BroadcastSerializer
  end

  # TODO: Remove this after we removed the old API
  def as_json(*)
    result = super(except: [ "channel", "beneficiary_filter" ])
    result["status"] = "initialized" if result["status"] == "pending"
    result
  end

  def updatable?
    status == "pending"
  end

  def mark_as_errored!(message)
    self.error_message = message
    self.error!
  end

  def not_yet_started?
    pending? || queued? || errored?
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(self)
  end
end
