module CSVSerializers
  class ResourceSerializer
    include SimpleSerializer

    timestamp_attributes :created_at, :updated_at
  end
end
