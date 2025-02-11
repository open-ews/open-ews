module CallFlowLogic
  class PlayMessage < CallFlowLogic::Base
    def to_xml(_options = {})
      Twilio::TwiML::VoiceResponse.new do |response|
        if (audio_url = event.broadcast&.audio_url)
          response.play(
            url: audio_url
          )
        else
          response.say(message: "No audio URL to play. Bye Bye")
        end
      end.to_s
    end
  end
end
