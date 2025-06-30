module LaosCountry
  class AddressLocality < Struct.new(:code, :name_en, :name_local, :subdivisions, :parent, keyword_init: true)
    def initialize(*)
      super(*)
      add_to_cache

      freeze
    end

    class << self
      def [](code)
        cache_data[code]
      end

      def all
        cache_data.values
      end

      def add_to_cache(key, address_locality)
        cache_data[key] = address_locality
      end

      private

      def cache_data
        @data ||= {}
      end
    end

    def subdivisions
      @subdivisions ||= []
    end

    private

    def add_to_cache
      self.class.add_to_cache(code, self)
    end
  end
end
