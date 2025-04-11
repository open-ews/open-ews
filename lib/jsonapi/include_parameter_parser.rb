module JSONAPI
  class IncludeParameterParser
    class Parser
      attr_reader :query_parameters

      def initialize(query_parameters)
        @query_parameters = query_parameters
      end

      def parse
        query_parameters.fetch(:include, "").split(/,\s*/).reject(&:blank?)
      end
    end

    def parse(...)
      Parser.new(...).parse
    end
  end
end
