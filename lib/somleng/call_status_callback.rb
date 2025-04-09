module Somleng
  CallStatusCallback = Data.define(:call_sid, :account_sid, :to, :from, :direction, :call_status, :call_duration)
end
