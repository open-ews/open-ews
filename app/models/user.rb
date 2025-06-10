class User < ApplicationRecord
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, reconfirmable: true

  belongs_to :account
  has_many :imports

  enumerize :locale, in: %w[en km]

  validates :name, :email, presence: true

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end
end
