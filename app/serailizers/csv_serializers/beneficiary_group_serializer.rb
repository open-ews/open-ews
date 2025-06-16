module CSVSerializers
  class BeneficiaryGroupSerializer < ResourceSerializer
    attributes :name

    attribute :members do |object|
      object.members.pluck(:phone_number).join(", ")
    end
  end
end
