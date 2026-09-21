module RspecApiDocumentation
  module DSL
    module Endpoint
      class Params
        def extended
          example.metadata.fetch(:parameters, {}).map do |param|
            p = Marshal.load(Marshal.dump(param))
            p[:value] = SetParam.new(self, nil, p).value

            unless p[:value]
              cur = extra_params

              # Filter out empty scope elements created by nested array indicators
              [ *p[:scope] ].reject { |s| s.to_s.empty? }.each do |scope|
                # If cur is an Array of Hashes (e.g. geocode: [{...}]), auto-unwrap the first element
                cur = cur.first if cur.is_a?(Array) && cur.first.is_a?(Hash)

                # Ensure cur is a Hash before indexing with a Symbol or String key
                cur = cur.is_a?(Hash) ? (cur[scope.to_sym] || cur[scope.to_s]) : nil
              end

              # When the current parameter is an array of objects, use the first one
              if cur.is_a?(Array) && cur.first.is_a?(Hash)
                cur = cur.first
                param[:scope] = param[:scope].dup << '' unless param[:scope].include?('')
              end

              p[:value] = cur.is_a?(Hash) ? (cur[p[:name].to_s] || cur[p[:name].to_sym]) : nil
            end

            p
          end
        end
      end
    end
  end
end
