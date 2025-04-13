class Event < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :account

  enumerize :type, in: %i[beneficiary.created beneficiary.deleted]
end
