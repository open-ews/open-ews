class BroadcastDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :Broadcast
  end

  def beneficiary_filter
    translatable_attributes = Beneficiary.enumerized_attributes.attributes

    object.beneficiary_filter.each_with_object({}) do |(key, filter), result|
      operator, value = filter.first
      value = translatable_attributes.fetch(key).values.find { it == value }&.text || value if translatable_attributes.include?(key)

      result[self.class.human_attribute_name(key)] = {
        I18n.t("filter_operators.#{operator}") => value
      }
    end
  end

  private

  def object
    __getobj__
  end
end
