# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "JSON"
  inflect.acronym "REST"
  inflect.acronym "API"
  inflect.acronym "EWS"
  inflect.acronym "URL"
  inflect.acronym "JSONAPI"
  inflect.acronym "ISO"
  inflect.acronym "CSV"
  inflect.acronym "TwiML"
  inflect.acronym "SMS"

  # Country codes
  inflect.acronym "KH"
  inflect.acronym "LA"
end

[ :km, :lo ].each do |locale|
  ActiveSupport::Inflector.inflections(locale) do |inflect|
    inflect.plural(/^(.*)$/u, '\1')
    inflect.singular(/^(.*)$/u, '\1')
  end
end
