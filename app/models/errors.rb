module Errors
  class ApplicationError < StandardError
    attr_reader :code, :definition

    def initialize(message = nil, code:)
      super(message || code.to_s.humanize)
      @code = Definitions.find(code).code
    end
  end

  class ImportError < ApplicationError; end

  module Definitions
    Error = Data.define(:code)

    COLLECTION = [
      Error.new(code: :no_matching_beneficiaries),
      Error.new(code: :account_not_configured_for_channel),
      Error.new(code: :audio_download_failed),
      Error.new(code: :import_contains_marked_for_deletion_flags),
      Error.new(code: :beneficiary_not_found),
      Error.new(code: :beneficiary_has_multiple_addresses),
      Error.new(code: :invalid_marked_for_deletion_flag),
      Error.new(code: :invalid_import_columns),
      Error.new(code: :validation_failed)
    ].freeze

    def self.find(code)
      COLLECTION.find(-> { raise(ArgumentError, "Unknown error: #{code}") }) { it.code == code.to_s.to_sym }
    end
  end
end
