class AppSubdomainConstraint
  def matches?(request)
    AppRequest.new(request).find_account.present?
  end
end
