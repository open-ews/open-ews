class BroadcastBeneficiaryGroup < ApplicationRecord
  belongs_to :broadcast
  belongs_to :beneficiary_group
end
