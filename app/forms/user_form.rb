class UserForm < ApplicationForm
  attribute :object, default: -> { User.new }
  attribute :name
  attribute :email
  attribute :account
  attribute :inviter

  validates :name, :email, presence: true
  validates :email, email_uniqueness: true, email_format: true, allow_blank: true

  delegate :persisted?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  def save
    return false if invalid?

    self.object = User.invite!(
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
