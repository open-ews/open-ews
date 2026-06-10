require "rails_helper"

module CountryAddressData
  RSpec.describe Myanmar do
    it "returns address localities in Myanmar" do
      result = CountryAddressData.address_data(:MM)

      expect(result).to be_an(Array)
      expect(result[0]).to be_a(CountryAddressData::Locality)
      expect(result[0]).to have_attributes(
        value: "MM-11",
        name_en: "Kachin",
        name_local: "ကချင်ပြည်နယ်"
      )
    end
  end
end
