require "rails_helper"

RSpec.describe EmailFormatValidator do
  it "validates the email uniqueness" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :email

      validates :email, email_format: true
    end

    expect(validatable_klass.new(email: nil).valid?).to be(false)
    expect(validatable_klass.new(email: "johndoe@").valid?).to be(false)
    expect(validatable_klass.new(email: "johndoe@example.com").valid?).to be(true)
  end
end
