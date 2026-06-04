class WebhookEndpoint < ApplicationRecord
  belongs_to :oauth_application, class_name: "Doorkeeper::Application"
  has_many :webhook_request_logs, dependent: :destroy

  validates :signing_secret, :url, presence: true
  validates :subscriptions, presence: true

  enumerize :subscriptions, in: Event::EVENT_TYPES, multiple: true

  scope :enabled, -> { where(enabled: true) }
  scope :for_account, ->(account) { joins(:oauth_application).where(oauth_applications: { owner_id: account.id }) }
  scope :subscribed_to, ->(event_type) { where("? = ANY(subscriptions)", event_type) }
end
