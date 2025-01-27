class ApplicationRequestSchema < Dry::Validation::Contract
  attr_reader :input_params

  option :resource, optional: true
  option :account, optional: true

  delegate :success?, :errors, to: :result

  register_macro(:phone_number_format) do
    key.failure(text: "is invalid") if key? && !Phony.plausible?(value)
  end

  register_macro(:url_format) do
    uri = URI.parse(value)
    isValid = (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host.present?

    key.failure(text: "is invalid") unless isValid
  rescue URI::InvalidURIError
    key.failure(text: "is invalid")
  end

  module Types
    include Dry.Types()

    Number = String.constructor do |string|
      string.gsub(/\D/, "") if string.present?
    end

    UpcaseString = String.constructor do |string|
      string.upcase if string.present?
    end
  end

  def initialize(input_params:, options: {})
    super(**options)

    @input_params = input_params.to_h.with_indifferent_access
  end

  def output
    result.to_h
  end

  private

  def result
    @result ||= call(input_params)
  end
end
