class AudioFileProcessorJob < ApplicationJob
  require "aws-sdk-s3"

  queue_as Rails.configuration.app_settings.fetch(:aws_sqs_high_priority_queue_name)

  def perform(broadcast)
    bucket_object_name = [
      generate_object_uuid,
      broadcast.audio_file.filename.sanitized
    ].join("-")

    bucket_object = s3_resource.bucket(
      audio_bucket
    ).object(bucket_object_name)

    audio_file = URI(broadcast.audio_file.url).open
    bucket_object.put(body: audio_file)

    broadcast.update!(audio_url: bucket_object.public_url)
  end

  private

  def audio_bucket
    Rails.configuration.app_settings.fetch(:audio_bucket)
  end

  def generate_object_uuid
    SecureRandom.uuid
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new
  end
end
