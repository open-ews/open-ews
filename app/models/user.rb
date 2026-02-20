class User < ApplicationRecord
  devise :two_factor_authenticatable
  ACCEPTED_AVATAR_CONTENT_TYPES = [ "image/png", "image/jpeg", "image/webp" ].freeze

  devise :invitable, :registerable, :two_factor_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, reconfirmable: true

  belongs_to :account
  has_many :imports, dependent: :destroy
  has_many :exports, dependent: :destroy

  has_one_attached :avatar

  enumerize :language, in: %w[en km lo ne], default: "en"

  validates :name, :email, presence: true
  validates :avatar, content_type: ACCEPTED_AVATAR_CONTENT_TYPES

  before_create :set_defaults

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  private

  def set_defaults
    self.otp_secret ||= User.generate_otp_secret
  end
end
