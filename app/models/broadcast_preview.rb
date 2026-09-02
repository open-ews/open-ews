class BroadcastPreview
  attr_reader :broadcast

  def initialize(broadcast)
    @broadcast = broadcast
  end

  def filtered_beneficiaries
    return Beneficiary.none if !beneficiary_filter.success? || beneficiary_filter.output.blank?

    target_areas_scope = FilterScopeQuery.new(
      Beneficiary,
      target_area_filter_fields,
      conjunction: :or
    ).apply

    beneficiaries_scope = FilterScopeQuery.new(
      Beneficiary,
      beneficiary_filter.output
    ).apply

    broadcast.account.beneficiaries.active
      .where.not(id: group_beneficiaries.select(:id))
      .merge(target_areas_scope)
      .merge(beneficiaries_scope)
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

  def target_area_filter_fields
    Hash(broadcast.target_areas["geocode"]).map do |field_name, values|
      field_definition = FieldDefinitions::TargetAreaFields.find_by!(name: field_name)
      FilterField.new(field_definition:, operator: :in, value: values)
    end
  end
end
