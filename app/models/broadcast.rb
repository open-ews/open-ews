class Broadcast < ApplicationRecord
  extend Enumerize

  AUDIO_CONTENT_TYPES = %w[audio/mpeg audio/mp3 audio/wav audio/x-wav].freeze

  include MetadataHelpers

  class StateMachine < StateMachine::ActiveRecord
    state :pending, initial: true, transitions_to: :queued
    state :queued, transitions_to: [ :running, :errored ]
    state :errored, transitions_to: :queued
    state :running, transitions_to: [ :stopped, :completed ]
    state :stopped, transitions_to: [ :running, :completed ]
    state :completed
  end

  store_accessor :settings
  accepts_nested_key_value_fields_for :settings

  enumerize :channel, in: [ :voice ]
  validates :channel, presence: true

  belongs_to :account
  has_many :alerts
  has_many :beneficiaries, through: :alerts
  has_many :delivery_attempts
  has_many :broadcast_beneficiary_groups
  has_many :beneficiary_groups, through: :broadcast_beneficiary_groups
  has_many :group_beneficiaries, through: :beneficiary_groups, source: :members, class_name: "Beneficiary"

  has_one_attached :audio_file

  validates :audio_file,
            file_size: {
              less_than_or_equal_to: 10.megabytes
            },
            file_content_type: {
              allow: AUDIO_CONTENT_TYPES
            },
            if: ->(broadcast) { broadcast.audio_file.attached? }

  delegate :pending?, :queued?, :errored?, :may_transition_to?, :transition_to!, to: :state_machine

  before_create :set_default_status

  # TODO: Remove this after we removed the old API
  def as_json(*)
    result = super(except: [ "channel", "beneficiary_filter" ])
    result["status"] = "initialized" if result["status"] == "pending" || result["status"] == "queued"
    result
  end

  def updatable?
    status == "pending"
  end

  def mark_as_errored!(message)
    transaction do
      state_machine.transition_to!(:errored)
      update!(error_message: message)
    end
  end

  private

  def state_machine
    StateMachine.new(self)
  end

  def set_default_status
    self.status ||= state_machine.current_state.name
  end
end
