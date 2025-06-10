require "rails_helper"

RSpec.describe EmailUniquenessValidator do
  it "validates the email format" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :email

      validates :email, email_uniqueness: true
    end

    create(:user, email: "johndoe@example.com")
    expect(validatable_klass.new(email: "johndoe@example.com").valid?).to be(false)
    expect(validatable_klass.new(email: "johndoe1@example.com").valid?).to be(true)
  end
end
