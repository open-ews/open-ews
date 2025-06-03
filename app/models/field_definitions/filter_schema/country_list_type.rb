module FieldDefinitions
  module FilterSchema
    class CountryListType < ListType
      def options_for_select
        results = options.fetch(:list_options).map do
          country = ISO3166::Country[it]
          localized_name = country.translations.fetch(I18n.locale.to_s, country.iso_short_name)

          [ localized_name, it ]
        end

        results.sort_by(&:first)
      end
    end
  end
end
