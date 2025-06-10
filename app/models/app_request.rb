class AppRequest
  attr_reader :request

  def initialize(request)
    @request = ActionDispatch::Request.new(request.env.except("HTTP_X_FORWARDED_HOST"))
  end

  def account_subdomain_request?
    _subdomain, *namespace = request.subdomains
    namespace == [ AppSettings.fetch(:app_subdomain) ]
  end

  def find_account
    Account.find_by(subdomain: account_subdomain) if account_subdomain_request?
  end

  def find_account!
    raise ActiveRecord::RecordNotFound unless account_subdomain_request?

    Account.find_by!(subdomain: account_subdomain)
  end

  def account_subdomain
    request.subdomains.first
  end
end
