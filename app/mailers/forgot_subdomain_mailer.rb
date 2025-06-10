class ForgotSubdomainMailer < ApplicationMailer
  helper ApplicationHelper

  def forgot_subdomain(user)
    @user = user
    bootstrap_mail(to: user.email, subject: "#{user.account.name} Account URL")
  end
end
