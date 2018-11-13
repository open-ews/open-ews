require "rails_helper"

RSpec.describe FetchRemoteCallJob do
  include_examples("aws_sqs_queue_url")

  describe "#perform" do
    it "fetches the remote call" do
      account = create(:account, :with_twilio_provider)
      phone_call = create_phone_call(account: account)
      stub_twilio_request(
        account: account,
        phone_call: phone_call,
        response: { body: { "status" => "completed" }.to_json }
      )
      job = described_class.new

      job.perform(phone_call.id)

      phone_call.reload
      assert_request_made!(account: account)
      expect(phone_call.remote_response.fetch("status")).to eq("completed")
      expect(phone_call).to be_completed
    end

    it "returns if there is no remote call id" do
      account = create(:account)
      phone_call = create_phone_call(
        account: account,
        status: PhoneCall::STATE_CREATED,
        remote_call_id: nil
      )
      job = described_class.new

      job.perform(phone_call.id)

      expect(phone_call).to be_created
    end

    def assert_request_made!(account:)
      authorization = authorization_header(request: WebMock.requests.last)
      expect(authorization).to eq("#{account.twilio_account_sid}:#{account.twilio_auth_token}")
    end

    def create_phone_call(account:, **options)
      super(
        account: account,
        status: PhoneCall::STATE_REMOTELY_QUEUED,
        remote_call_id: SecureRandom.uuid,
        **options
      )
    end

    def stub_twilio_request(account:, phone_call:, response:)
      stub_request(
        :get,
        "https://api.twilio.com/2010-04-01/Accounts/#{account.twilio_account_sid}/Calls/#{phone_call.remote_call_id}.json"
      ).to_return(response)
    end
  end
end
