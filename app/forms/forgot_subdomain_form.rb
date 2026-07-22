class ForgotSubdomainForm < ApplicationForm
  attribute :email

  validates :email, presence: true
  validate :validate_email_exists

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def save
    return false if invalid?

    ForgotSubdomainMailer.forgot_subdomain(User.find_by!(email:)).deliver_later

    true
  end

  private

  def validate_email_exists
    errors.add(:email, :not_found) unless User.exists?(email:)
  end
end
