class BroadcastPreview
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def filtered_beneficiaries
    return Beneficiary.none if !beneficiary_filter.success? || beneficiary_filter.output.blank?

    FilterScopeQuery.new(
      broadcast.account.beneficiaries.active,
      beneficiary_filter.output
    ).apply.where.not(id: group_beneficiaries.select(:id))
  end

  def group_beneficiaries
    broadcast.group_beneficiaries.active
  end

  def beneficiaries
    Beneficiary.where(id: filtered_beneficiaries.select(:id)).or(Beneficiary.where(id: group_beneficiaries.select(:id))).distinct
  end

  private

  def beneficiary_filter
    @beneficiary_filter ||= BeneficiaryFilter.new(input_params: broadcast.beneficiary_filter)
  end
end
