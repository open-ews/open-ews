class BroadcastBeneficiaryGroup < ApplicationRecord
  belongs_to :broadcast
  belongs_to :beneficiary_group

  validate :validate_associations_belong_to_the_same_account

  private

  def validate_associations_belong_to_the_same_account
    return if broadcast.account_id == beneficiary_group.account_id

    errors.add(:beneficiary_group, :invalid)
  end
end
