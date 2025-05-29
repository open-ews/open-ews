class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.model_name
    ActiveModel::Name.new(self, nil, "ApplicationForm")
  end

  def self.attributes
    attribute_names.each_with_object({}) do |name, result|
      result[name] = type_for_attribute(name)
    end
  end
end
