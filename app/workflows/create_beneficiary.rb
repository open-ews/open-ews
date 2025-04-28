class CreateBeneficiary < ApplicationWorkflow
  attr_reader :beneficiary_params, :address_params

  def initialize(address: {}, **params)
    super()
    @address_params = address
    @beneficiary_params = params
  end

  def call
    ApplicationRecord.transaction do
      beneficiary = Beneficiary.create!(beneficiary_params)
      event = create_event(beneficiary)
      beneficiary.addresses.create!(address_params) if address_params.present?
      beneficiary
    end
  end

  private

  def create_event(beneficiary)
    Event.create!(
      account: beneficiary.account,
      type: "beneficiary.created",
      details: BeneficiaryEventSerializer.new(beneficiary).serializable_hash
    )
  end
end
