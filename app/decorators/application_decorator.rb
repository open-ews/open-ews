class ApplicationDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :decorated_class

    def decorated_class
      name.delete_suffix("Decorator").safe_constantize
    end
  end

  def object
    __getobj__
  end
end
