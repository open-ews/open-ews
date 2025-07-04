# custom component requires input group wrapper
module SimpleFormComponents
  module InputGroup
    def append(_wrapper_options = nil)
      template.content_tag(:span, options[:append], class: "input-group-text")
    end
  end
end

# Register the component in Simple Form.
SimpleForm.include_component(SimpleFormComponents::InputGroup)
