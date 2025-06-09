class ForgotSubdomainMailer < ApplicationMailer
  def forgot_subdomain(user)
    @user = user
    bootstrap_mail(to: user.email, subject: "OpenEWS - Forgot Subdomain?")
  end
end
