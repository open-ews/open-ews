class ForgotSubdomainMailerPreview < ActionMailer::Preview
  def forgot_subdomain
    ForgotSubdomainMailer.forgot_subdomain(User.first!)
  end
end
