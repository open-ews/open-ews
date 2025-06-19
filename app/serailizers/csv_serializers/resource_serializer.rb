module CSVSerializers
  class ResourceSerializer
    include SimpleSerializer

    attributes :id

    timestamp_attributes :created_at, :updated_at
  end
end
