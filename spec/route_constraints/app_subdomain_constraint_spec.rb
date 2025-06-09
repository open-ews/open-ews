require "rails_helper"

RSpec.describe AppSubdomainConstraint do
  it "handles handles app subdomains" do
    create(:account, subdomain: "foobar")
    constraint = AppSubdomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "foobar.app.open-ews.org"
    )

    result = constraint.matches?(request)

    expect(result).to be(true)
  end

  it "rejects other subdomains" do
    create(:account, subdomain: "foobar")
    constraint = AppSubdomainConstraint.new
    request = stub_request(
      "HTTP_HOST" => "foobar.baz.open-ews.org"
    )

    result = constraint.matches?(request)

    expect(result).to be(false)
  end

  def stub_request(headers)
    ActionDispatch::TestRequest.create(headers)
  end
end
