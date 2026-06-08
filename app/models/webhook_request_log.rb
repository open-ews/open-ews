class WebhookRequestLog < ApplicationRecord
  belongs_to :event
  belongs_to :webhook_endpoint

  validates :http_status_code, :payload, :url, presence: true

  scope :failed, -> { where(failed: true) }
end
