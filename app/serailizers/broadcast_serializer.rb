class BroadcastSerializer < ResourceSerializer
  attributes :channel, :audio_url, :metadata, :beneficiary_filter, :status
  has_many :beneficiary_groups, serializer: BeneficiaryGroupSerializer
end
