class DeviseMailer < Devise::Mailer
  layout "account_mailer"
  helper ApplicationHelper

  private

  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)
    @account = record.account
    @host = record.account.subdomain_host

    bootstrap_mail(headers_for(action, opts), &block)
  end
end
