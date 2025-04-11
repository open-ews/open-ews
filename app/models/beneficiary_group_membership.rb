class BeneficiaryGroupMembership < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :beneficiary_group
end
