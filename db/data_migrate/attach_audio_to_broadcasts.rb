module DataMigrate
  class AttachAudioToBroadcasts
    def call
      Broadcast.where(audio_url: "").update_all(audio_url: nil)
      Broadcast.where.not(audio_url: nil).find_each do |broadcast|
        puts "#{Time.current} attaching #{broadcast.audio_url} to #{broadcast.id} from #{broadcast.created_at}"
        if broadcast.audio_file.attached?
          puts "Skipping, already attached"
          next
        elsif broadcast.audio_url.start_with?("http://ews1294.info") || broadcast.audio_url.start_with?("http://ews1294.com") || broadcast.audio_url.start_with?("http://mamainfo.org/") || broadcast.audio_url.start_with?("https://demo.twilio.com") || broadcast.audio_url.start_with?("http://demo.twilio.com") || broadcast.audio_url.start_with?("https://example.com")
          puts "Skipping, unreachable audio URL"
          next
        end

        attach_audio(broadcast)
      end
    end

    private

    def attach_audio(broadcast)
      DownloadBroadcastAudioFile.call(broadcast)
    rescue DownloadBroadcastAudioFile::Error
    end
  end
end

DataMigrate::AttachAudioToBroadcasts.new.call if Rails.env.production?
