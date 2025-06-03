module API
  module V1
    module Broadcasts
      class AudioFilesController < API::V1::BaseController
        include ActiveStorage::SetCurrent

        def show
          if broadcast.audio_file.attached?
            redirect_to broadcast.audio_file.url, allow_other_host: true
          else
            head :not_acceptable
          end
        end

        private

        def broadcast
          @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
        end
      end
    end
  end
end
