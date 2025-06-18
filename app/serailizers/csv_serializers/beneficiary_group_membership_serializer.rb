module CSVSerializers
  class BeneficiaryGroupMembershipSerializer < ResourceSerializer
    attributes :beneficiary_id

    attribute :phone_number do |object|
      object.beneficiary.phone_number
    end
  end
end
