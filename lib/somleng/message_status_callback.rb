module Somleng
  MessageStatusCallback = Data.define(:message_sid, :account_sid, :to, :from, :body, :message_status)
end
