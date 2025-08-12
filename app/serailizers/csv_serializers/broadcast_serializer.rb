module CSVSerializers
  class BroadcastSerializer < ResourceSerializer
    has_associations :beneficiary_groups

    attributes :channel, :audio_url, :message, :beneficiary_filter, :status, :error_code

    attribute :beneficiary_groups do |object|
      object.beneficiary_groups.pluck(:name)
    end
  end
end
