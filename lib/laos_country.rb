require "yaml"

require_relative "laos_country/address_locality"
require_relative "laos_country/province"
require_relative "laos_country/district"

module LaosCountry
  def self.initialize!
    data = YAML.load_file(File.join(__dir__, "laos_country", "data", "data.yaml"))
    data.deep_symbolize_keys!

    data.fetch(:provinces).each do |province|
      Province.new(**province)
    end
  end
end
