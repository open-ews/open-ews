class BeneficiaryGroupSerializer < ResourceSerializer
  attributes :name
  has_many :members, serializer: BeneficiarySerializer
end
