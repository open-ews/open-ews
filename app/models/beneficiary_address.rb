class BeneficiaryAddress < ApplicationRecord
  extend Enumerize

  enumerize :iso_country_code, in: ISO3166::Country.codes.freeze

  belongs_to :beneficiary

  validates :iso_region_code,
    :administrative_division_level_2_code,
    :administrative_division_level_2_name,
    :administrative_division_level_3_code,
    :administrative_division_level_3_name,
    :administrative_division_level_4_code,
    :administrative_division_level_4_name,
    length: { maximum: 255 }


  def self.address_data(iso_country_code)
    @address_data ||= {}

    @address_data[iso_country_code] ||= Pumi::Province.all.map do |province|
      {
        id: province.iso3166_2,
        text: province.name_latin,
        children: Pumi::District.where(province_id: province.id).map do |district|
          {
            id: district.id,
            text: district.name_latin,
            children: Pumi::Commune.where(district_id: district.id).map do |commune|
              {
                id: commune.id,
                text: commune.name_latin
              }
            end
          }
        end
      }
    end
  end
end
