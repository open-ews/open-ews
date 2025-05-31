class FilterFieldForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :operator
  attribute :value, FormDataType.new
end
