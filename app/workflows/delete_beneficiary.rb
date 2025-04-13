class DeleteBeneficiary < ApplicationWorkflow
  attr_reader :beneficiary

  def initialize(beneficiary)
    super()
    @beneficiary = beneficiary
  end

  def call
    Beneficiary.transaction do
      Event.create!(account: beneficiary.account, type: "beneficiary.deleted")
      beneficiary.destroy!
    end
  end
end
