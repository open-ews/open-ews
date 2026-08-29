require "rails_helper"

module CountryAddressData
  RSpec.describe Myanmar do
    it "returns address localities in Myanmar" do
      result = CountryAddressData.address_data(:MM)

      expect(result).to have_attributes(
        local_language: :my,
        localities: include(
          have_attributes(
            value: "MM-11",
            name_en: "Kachin",
            name_local: "ကချင်ပြည်နယ်"
          )
        )
      )
    end
  end
end
