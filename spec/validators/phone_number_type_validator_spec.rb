require "rails_helper"

RSpec.describe PhoneNumberTypeValidator do
  it "validates the phone number" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :phone_number

      validates :phone_number, phone_number_type: true
    end

    expect(validatable_klass.new(phone_number: nil).valid?).to eq(false)
    expect(validatable_klass.new(phone_number: "").valid?).to eq(false)
    expect(validatable_klass.new(phone_number: "1294").valid?).to eq(false)
    expect(validatable_klass.new(phone_number: "8551678911").valid?).to eq(false) # Too short
    expect(validatable_klass.new(phone_number: "855167891111").valid?).to eq(false) # Too long
    expect(validatable_klass.new(phone_number: "016789111").valid?).to eq(false) # Non E.164
    expect(validatable_klass.new(phone_number: "85516789111").valid?).to eq(true)
  end
end
