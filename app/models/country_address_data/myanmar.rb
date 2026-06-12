module CountryAddressData
  class Myanmar
    class << self
      def address_data
        @address_data ||= [
          CountryAddressData::Locality.new(
            value: "MM-11",
            name_en: "Kachin",
            name_local: "ကချင်ပြည်နယ်",
            subdivisions: [
              CountryAddressData::Locality.new(
                value: "MMR001D001",
                name_en: "Myitkyina",
                name_local: "မြစ်ကြီးနားခရိုင်",
                subdivisions: [
                  CountryAddressData::Locality.new(
                    value: "MMR001002",
                    name_en: "Waingmaw",
                    name_local: "ဝိုင်းမော်",
                    subdivisions: [
                      CountryAddressData::Locality.new(
                        value: "MMR001002006",
                        name_en: "Mong Nar",
                        name_local: "မိုင်းနား",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001002006216830",
                            name_en: "Mat Khaw Ti",
                            name_local: "မတ်ခေါတီ",
                            subdivisions: []
                          ),
                          CountryAddressData::Locality.new(
                            value: "MMR001002006216832",
                            name_en: "La Bang",
                            name_local: "လဘန်",
                            subdivisions: []
                          )
                        ]
                      ),
                      CountryAddressData::Locality.new(
                        value: "MMR001002014",
                        name_en: "Nawng Ching",
                        name_local: "နောင်ချိန်း",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001002014165751",
                            name_en: "Nawng Ching",
                            name_local: "နောင်ချိန်း",
                            subdivisions: []
                          )
                        ]
                      )
                    ]
                  ),
                  CountryAddressData::Locality.new(
                    value: "MMR001003",
                    name_en: "Injangyang",
                    name_local: "အင်ဂျန်းယန်",
                    subdivisions: [
                      CountryAddressData::Locality.new(
                        value: "MMR001003002",
                        name_en: "Shagri Bum",
                        name_local: "ရှဂရီဘွမ်",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001003002165913",
                            name_en: "Aung Ra",
                            name_local: "အောင်ရာ",
                            subdivisions: []
                          )
                        ]
                      ),
                      CountryAddressData::Locality.new(
                        value: "MMR001003006",
                        name_en: "In Dung Yang",
                        name_local: "အင်ဒုံးယန်",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001003006C220400",
                            name_en: "U Lawng Yang",
                            name_local: "အူလောန်ယန်",
                            subdivisions: []
                          ),
                          CountryAddressData::Locality.new(
                            value: "MMR001003006220401",
                            name_en: "Ju Ba Li",
                            name_local: "‌ဂျူဗလီ",
                            subdivisions: []
                          )
                        ]
                      )
                    ]
                  ),
                  CountryAddressData::Locality.new(
                    value: "MMR001005",
                    name_en: "Chipwi",
                    name_local: "ချီ​ဖွေ",
                    subdivisions: [
                      CountryAddressData::Locality.new(
                        value: "MMR001005015",
                        name_en: "Man Dungt",
                        name_local: "မန့်ဒုန့်",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001005015166321",
                            name_en: "Man Dungt",
                            name_local: "မန့်ဒုန့်",
                            subdivisions: []
                          )
                        ]
                      ),
                      CountryAddressData::Locality.new(
                        value: "MMR001005004",
                        name_en: "Myaw Maw Par",
                        name_local: "မျောမောပါ",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001005004220455",
                            name_en: "Myaw Maw Par",
                            name_local: "မျောမောပါ",
                            subdivisions: []
                          )
                        ]
                      ),
                      CountryAddressData::Locality.new(
                        value: "MMR001005701",
                        name_en: "Chipwi",
                        name_local: "ချီ​ဖွေ",
                        subdivisions: [
                          CountryAddressData::Locality.new(
                            value: "MMR001005701501",
                            name_en: "Yit Law Hkaung",
                            name_local: "ရစ်လောခေါင်ရပ်ကွက်",
                            subdivisions: []
                          ),
                          CountryAddressData::Locality.new(
                            value: "MMR001005701502",
                            name_en: "Oke Kat",
                            name_local: "ဥက္ကပ်ရပ်ကွက်",
                            subdivisions: []
                          ),
                          CountryAddressData::Locality.new(
                            value: "MMR001005701503",
                            name_en: "Ba Leit Dan",
                            name_local: "ဘာလဲ့ဒမ်ရပ်ကွက်",
                            subdivisions: []
                          ),
                          CountryAddressData::Locality.new(
                            value: "MMR001005701504",
                            name_en: "Kan Paing Yan",
                            name_local: "ကန်ပိုင်ယံရပ်ကွက်",
                            subdivisions: []
                          )
                        ]
                      )
                    ]
                  )
                ]
              )
            ]
          )
        ]
      end
    end
  end
end
