class UserForm < ApplicationForm
  attribute :name
  attribute :email
  attribute :user, default: -> { User.new }
  attribute :account
  attribute :inviter

  validates :name, :email, presence: true
  validates :email, email_uniqueness: true, email_format: true, allow_blank: true

  delegate :persisted?, :id, to: :user

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def self.initialize_with(user)
    new(
      user:,
      account: user.account,
      name: user.name,
      email: user.email
    )
  end

  def save
    return false if invalid?

    self.user = User.invite!(
      {
        name:,
        email:,
        account:
      },
      inviter
    )

    true
  end
end
