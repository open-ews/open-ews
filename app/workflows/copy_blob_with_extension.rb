require "aws-sdk-s3"

class CopyBlobWithExtension < ApplicationWorkflow
  attr_reader :blob, :bucket, :client

  def initialize(blob, bucket:, **options)
    super()
    @blob = blob
    @bucket = bucket
    @client = options.fetch(:client) { Aws::S3::Client.new }
  end

  def call
    client.copy_object(
      bucket:,
      copy_source: blob.key,
      key: BlobWithExtension.new(blob).key
    )
  end
end
