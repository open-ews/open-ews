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
  end
end

# Register the component in Simple Form.
SimpleForm.include_component(SimpleFormComponents::InputGroup)
