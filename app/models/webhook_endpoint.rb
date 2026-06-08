class WebhookEndpoint < ApplicationRecord
  belongs_to :oauth_application, class_name: "Doorkeeper::Application"
  has_many :webhook_request_logs

  enumerize :subscriptions, in: Event::EVENT_TYPES, multiple: true
  encrypts :signing_secret

  scope :enabled, -> { where(enabled: true) }
  scope :for_account, ->(account) { joins(:oauth_application).where(oauth_applications: { owner_id: account.id }) }
  scope :subscribed_to, ->(event_type) { where("? = ANY(subscriptions)", event_type) }

  validates :url, presence: true
  validates :subscriptions, presence: true

  before_create :generate_signing_secret

  private

  def generate_signing_secret
    self.signing_secret ||= SecureRandom.alphanumeric(32)
  end
end
