class BeneficiaryGroup < ApplicationRecord
  belongs_to :account
  has_many :memberships, class_name: "BeneficiaryGroupMembership"
  has_many :members, through: :memberships, source: :beneficiary, class_name: "Beneficiary"

  validates :name, presence: true
end
