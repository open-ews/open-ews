module CSVSerializers
  class BroadcastSerializer < ResourceSerializer
    attributes :channel, :audio_url, :beneficiary_filter, :status, :error_code

    attribute :beneficiary_groups do |object|
      object.beneficiary_groups.pluck(:name).join(", ")
    end
  end
end
