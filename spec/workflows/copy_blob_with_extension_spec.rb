require "rails_helper"

RSpec.describe CopyBlobWithExtension do
  it "copies the blob with adding the file extension" do
    blob = create(:active_storage_attachment, filename: "test.mp3")
    client = Aws::S3::Client.new(stub_responses: true)

    CopyBlobWithExtension.call(blob, bucket: "my-bucket", client:)

    expect(client.api_requests).to contain_exactly(
      hash_including(
        operation_name: :copy_object,
        params: {
          bucket: "my-bucket",
          copy_source: blob.key,
          key: end_with(".mp3")
        }
      )
    )
  end
end
