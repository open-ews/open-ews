require_relative "application_responder"

class JSONAPIResponder < ApplicationResponder
  def display(resource, given_options = {})
    serializer_class = options.delete(:serializer_class) || resource.jsonapi_serializer_class
    decorator_class = options.key?(:decorator_class) ? options.fetch(:decorator_class) : resource.decorator_class
    serializer_options = options.delete(:serializer_options) || {}
    pagination_options = options.delete(:pagination_options) || {}

    serializer_options[:include] ||= include_parameter

    if resource_is_collection?(resource)
      if serializer_options.fetch(:pagination, true) != false
        pagination = JSONAPIPagination.new(resource, request.original_url, pagination_options:)
        links = serializer_options.fetch(:links, {})
        serializer_options[:links] = pagination.links.merge(links)
        resource = pagination.paginated_collection
      end

      resource = resource.map(&:decorated) if decorator_class.present?
    else
      resource = resource.decorated
    end

    super(serializer_class.new(resource, serializer_options), given_options)
  end

  def api_behavior(*args, &block)
    return display(resource, status: :ok) if put? || patch?

    super
  end

  private

  def resource_is_collection?(resource)
    resource.respond_to?(:size) && !resource.respond_to?(:each_pair)
  end

  def include_parameter
    JSONAPI::IncludeParameterParser.new.parse(request.query_parameters)
  end
end
