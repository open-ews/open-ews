# custom component requires input group wrapper
module SimpleFormComponents
  module InputGroup
    def append(_wrapper_options = nil)
      template.content_tag(:span, options[:append], class: "input-group-text")
    end

    def warning(_wrapper_options = nil)
      return if options[:warning].blank?

      template.content_tag(:i, nil, class: "icon ti ti-exclamation-circle") + " " +
      template.content_tag(:span, options[:warning])
    end

    def info(_wrapper_options = nil)
      return if options[:info].blank?

      template.content_tag(:i, nil, class: "icon ti ti-info-circle") + " " +
      template.content_tag(:span, options[:info])
    end
  end
end

# Register the component in Simple Form.
SimpleForm.include_component(SimpleFormComponents::InputGroup)
