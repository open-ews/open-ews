module LaosCountry
  class Province < AddressLocality
    def initialize(**args)
      subdivisions = args.delete(:districts).map { |district| District.new(**district, parent: self) }

      super(**args, subdivisions: subdivisions)
    end

    def districts
      subdivisions
    end
  end
end
