class DeleteBeneficiary < ApplicationWorkflow
  attr_reader :beneficiary

  def initialize(beneficiary)
    super()
    @beneficiary = beneficiary
  end

  def call
    Beneficiary.transaction do
      create_event
      beneficiary.destroy!
    end
  end

  private

  def create_event
    Event.create!(
      account: beneficiary.account,
      type: "beneficiary.deleted",
      details: BeneficiaryEventSerializer.new(beneficiary).serializable_hash
    )
  end
end
