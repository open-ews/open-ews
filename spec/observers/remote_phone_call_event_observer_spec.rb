require "rails_helper"

RSpec.describe RemotePhoneCallEventObserver do
  include FactoryHelpers

  describe "#remote_phone_call_event_initialized(remote_phone_call_event)" do
    class MyCallFlowLogic < CallFlowLogic::Base; end

    it "handles new phone calls" do
      register_call_flow_logic(MyCallFlowLogic)
      account = create_account(call_flow_logic: MyCallFlowLogic)
      event = build_event(account: account)

      subject.remote_phone_call_event_initialized(event)

      expect(event.errors).to be_empty
      expect(event.remote_call_id).to eq(event.details["CallSid"])
      expect(event.remote_direction).to eq(event.details["Direction"])
      expect(event.call_flow_logic).to eq(MyCallFlowLogic.to_s)
      expect(event.phone_call.call_flow_logic).to eq(event.call_flow_logic)
      expect(event.phone_call).to be_present
      expect(event.phone_call.remote_call_id).to eq(event.remote_call_id)
      expect(event.phone_call.remote_direction).to eq(event.remote_direction)
      expect(event.phone_call.msisdn).to eq(event.details["From"])
      expect(event.phone_call.remote_status).to eq(event.details["CallStatus"])
    end

    it "handles existing phone calls" do
      register_call_flow_logic(MyCallFlowLogic)
      account = create_account(call_flow_logic: MyCallFlowLogic)
      phone_call = create_phone_call(
        account: account,
        call_flow_logic: CallFlowLogic::HelloWorld,
        remote_call_id: SecureRandom.uuid
      )
      event = build_event(account: account, remote_call_id: phone_call.remote_call_id)

      subject.remote_phone_call_event_initialized(event)

      expect(event.phone_call).to eq(phone_call)
      expect(event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    end

    it "handles invalid call flow logic for existing phone calls" do
      account = create_account
      phone_call = create_phone_call(
        account: account,
        remote_call_id: SecureRandom.uuid
      )
      phone_call.update_column(:call_flow_logic, "Callout")
      event = build_event(account: account, remote_call_id: phone_call.remote_call_id)

      subject.remote_phone_call_event_initialized(event)

      expect(event.phone_call).to eq(phone_call)
      expect(event.call_flow_logic).to eq(CallFlowLogic::HelloWorld.to_s)
    end

    def build_event(account:, call_flow_logic: nil, remote_call_id: nil)
      build(
        :remote_phone_call_event,
        call_flow_logic: call_flow_logic,
        details: generate_event_details(
          account_sid: account.somleng_account_sid,
          remote_call_id: remote_call_id
        ),
        build_phone_call: false
      )
    end

    def create_account(call_flow_logic: nil)
      create(
        :account,
        somleng_account_sid: generate(:somleng_account_sid),
        call_flow_logic: call_flow_logic.to_s.presence
      )
    end

    def register_call_flow_logic(call_flow_logic)
      CallFlowLogic::Base.register(call_flow_logic.to_s)
    end

    def generate_event_details(remote_call_id: nil, account_sid: nil)
      details = generate(:twilio_remote_call_event_details)
      details["CallSid"] = remote_call_id if remote_call_id
      details["AccountSid"] = account_sid if account_sid
      details
    end
  end
end
