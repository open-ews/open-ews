class BeneficiaryGroupMembership < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :beneficiary_group

  validate :validate_associations_belong_to_the_same_account

  private

  def validate_associations_belong_to_the_same_account
    return if beneficiary.account == beneficiary_group.account

    errors.add(:beneficiary_group, :invalid)
  end
end
