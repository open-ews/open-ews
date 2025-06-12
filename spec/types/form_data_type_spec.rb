require "rails_helper"

RSpec.describe FormDataType do
  it "handles form data" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :my_attribute, FormDataType.new
    end

    expect(klass.new(my_attribute: "").my_attribute).to be_nil
    expect(klass.new(my_attribute: [ "foo", "" ]).my_attribute).to eq([ "foo" ])
  end
end
