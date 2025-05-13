class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :registerable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :async

  AVAILABLE_LOCALES = %w[en km].freeze

  belongs_to :account
  has_many :imports

  validates_inclusion_of :locale, in: AVAILABLE_LOCALES
end
