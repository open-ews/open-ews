class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.attributes
    attribute_names.each_with_object({}) do |name, result|
      result[name] = type_for_attribute(name)
    end
  end
end
