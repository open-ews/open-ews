module BatchOperation
  class Base < ApplicationRecord
    include CustomRoutesHelper["batch_operations"]
    include AASM

    PERMITTED_API_TYPES = [
      "BatchOperation::CalloutPopulation"
    ].freeze

    self.table_name = :batch_operations

    include CustomStoreReaders
    include MetadataHelpers

    belongs_to :account

    validates :type, presence: true
    validates :parameters, json: true

    def self.from_type_param(type)
      PERMITTED_API_TYPES.include?(type) ? type.constantize : where(type: PERMITTED_API_TYPES)
    end

    aasm column: :status, skip_validation_on_save: true do
      state :preview, initial: true
      state :queued
      state :running
      state :finished

      event :queue, after_commit: :run_later do
        transitions(from: :preview, to: :queued)
      end

      event :start do
        transitions(
          from: %i[queued running],
          to: :running
        )
      end

      event :finish do
        transitions(
          from: :running,
          to: :finished
        )
      end
    end

    def serializable_hash(options = nil)
      options ||= {}
      super(
        {
          methods: :type
        }.merge(options)
      )
    end

    private

    def run_later
      RunBatchOperationJob.perform_later(self)
    end
  end
end
