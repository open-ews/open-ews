class ApplicationRecord < ActiveRecord::Base
  extend Enumerize

  include SerializableResource
  include DecoratableResource

  primary_abstract_class

  scope :latest_first, -> { order(id: :desc) }
end
