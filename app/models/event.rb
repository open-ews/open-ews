class Event < ApplicationRecord
  self.inheritance_column = :_type_disabled

  EVENT_TYPES = %i[beneficiary.created beneficiary.deleted broadcast.created broadcast.updated].freeze

  belongs_to :account
  has_many :webhook_request_logs, dependent: :destroy

  enumerize :type, in: EVENT_TYPES
end
