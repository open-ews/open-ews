class User < ApplicationRecord
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  belongs_to :account
  has_many :imports

  enumerize :locale, in: %w[en km]

  validates :name, :email, presence: true
end
