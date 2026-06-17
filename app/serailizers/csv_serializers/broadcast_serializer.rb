module CSVSerializers
  class BroadcastSerializer < ResourceSerializer
    has_associations :beneficiary_groups

    attributes :name, :audio_url, :message, :beneficiary_filter, :status, :error_code

    attribute :beneficiary_groups do |object|
      object.beneficiary_groups.pluck(:name)
    end

    attribute :channels do |object|
      Array(object.channel)
    end
  end
end
