class TwiMLBuilder
  def play(url)
    Twilio::TwiML::VoiceResponse.new do |response|
      response.play(url:)
    end
  end
end
