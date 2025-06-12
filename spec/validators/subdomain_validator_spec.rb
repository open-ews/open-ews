require "rails_helper"

RSpec.describe SubdomainValidator do
  it "validates a subdomain" do
    validatable_klass = Struct.new(:subdomain) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :subdomain, subdomain: true
    end

    existing_account = create(:account)

    expect(validatable_klass.new("my-company").valid?).to be(true)
    expect(validatable_klass.new(existing_account.subdomain).valid?).to be(false)
    expect(validatable_klass.new(nil).valid?).to be(false)
    expect(validatable_klass.new("a").valid?).to be(false)
  end
end
