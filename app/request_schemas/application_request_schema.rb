class ApplicationRequestSchema < Dry::Validation::Contract
  Types = FieldDefinitions::Types

  attr_reader :input_params

  option :resource, optional: true
  option :account, optional: true
  option :phone_number_validator, default: -> { PhoneNumberValidator.new }

  delegate :success?, :context, :errors, to: :result

  register_macro(:phone_number_format) do
    key.failure(text: "is invalid") if key? && !phone_number_validator.valid?(value)
  end

  register_macro(:url_format) do
    next unless value.present?

    uri = URI.parse(value)
    is_valid = (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.host.present?

    key.failure(text: "is invalid") unless is_valid
  rescue URI::InvalidURIError
    key.failure(text: "is invalid")
  end

  register_macro(:beneficiary_groups) do
    next unless key?

    next if account.beneficiary_groups.where(id: value.pluck(:id)).count == value.pluck(:id).size
    key.failure(text: "is invalid")
  end

  # NOTE: composable contracts
  #
  # params do
  #   required(:a).hash(OtherContract.schema)
  # end
  #
  # rule(:a).validate(contract: OtherContract)
  #
  register_macro(:contract) do |macro:|
    contract_instance = macro.args[0]
    contract_result = contract_instance.new(input_params: value)
    unless contract_result.success?
      errors = contract_result.errors
      errors.each do |error|
        key(key.path.to_a + error.path).failure(error.text)
      end
    end
  end

  def initialize(input_params:, options: {})
    super(**options)

    @input_params = input_params.to_h.with_indifferent_access
    parse_json_filter_param!
  end

  def output
    result.to_h
  end

  private

  # NOTE: GET requests submit `filter` as bracket-nested query params, e.g.
  # `filter[gender][eq]=M`. That encoding can't represent an $or across
  # different fields (Rack can only tell array items apart by a repeated key,
  # so `$or: [{gender: ...}, {created_at: ...}]` gets silently merged into one
  # AND'd item). Accept `filter` as a JSON-encoded string too, so clients that
  # need $and/$or can send `?filter=%7B%22%24or%22...%7D` instead.
  def parse_json_filter_param!
    return unless input_params[:filter].is_a?(String)

    input_params[:filter] = JSON.parse(input_params[:filter]).with_indifferent_access
  rescue JSON::ParserError
    nil
  end

  def result
    @result ||= call(input_params)
  end
end
