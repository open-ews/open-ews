module Filter
  module Resource
    class Broadcast < Filter::Resource::Base
      private

      def filter_params
        params.slice(:status)
      end
    end
  end
end
