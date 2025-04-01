class CallStatusCallbackRequestSchema < ApplicationRequestSchema
  params do
    required(:CallSid).filled(:string)
    required(:From).filled(:string)
    required(:To).filled(:string)
    required(:Direction).filled(:string)
    required(:CallStatus).filled(:string)
    required(:AccountSid).filled(:string)
    optional(:ApiVersion).filled(:string, eql?: "2010-04-01")
    optional(:CallDuration).filled(:integer)
  end
end
