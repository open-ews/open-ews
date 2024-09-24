class Contact < ApplicationRecord
  include MsisdnHelpers
  include MetadataHelpers

  belongs_to :account

  has_many :callout_participations,
           dependent: :restrict_with_error

  has_many :callouts,
           through: :callout_participations

  has_many :phone_calls,
           dependent: :restrict_with_error

  has_many :remote_phone_call_events,
           through: :phone_calls

  delegate :call_flow_logic,
           to: :account,
           allow_nil: true
end
