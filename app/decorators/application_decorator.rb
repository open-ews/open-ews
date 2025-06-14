class ApplicationDecorator < SimpleDelegator
  def self.model_name
    decorated_class.model_name
  end

  def self.human_attribute_name(*)
    decorated_class.human_attribute_name(*)
  end

  def self.decorated_class
    name.delete_suffix("Decorator").constantize
  end

  def object
    __getobj__
  end
end
