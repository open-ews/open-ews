module FieldDefinitions
  module Types
    include Dry.Types()

    Number = String.constructor do |string|
      string.gsub(/\D/, "") if string.present?
    end

    UpcaseString = String.constructor do |string|
      string.upcase if string.present?
    end

    ChannelType = String.constructor do |string|
      case string
      when "voice"
        "voice_call"
      end
    end
  end
end
