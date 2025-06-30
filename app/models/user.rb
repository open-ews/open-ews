class User < ApplicationRecord
  ACCEPTED_AVATAR_CONTENT_TYPES = [ "image/png", "image/jpeg", "image/webp" ].freeze

  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, reconfirmable: true

  belongs_to :account
  has_many :imports
  has_many :exports

  has_one_attached :avatar

  enumerize :language, in: %w[en km lo], default: "en"

  validates :name, :email, presence: true
  validates :avatar, content_type: ACCEPTED_AVATAR_CONTENT_TYPES

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end
end
