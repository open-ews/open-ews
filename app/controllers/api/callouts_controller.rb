module API
  class CalloutsController < API::BaseController
    def index
      respond_with(:api, paginate(scope))
    end

    def create
      @broadcast = Broadcast.new(account: current_account, channel: :voice, **permitted_params)
      if @broadcast.audio_url.present?
        @broadcast.save
      else
        @broadcast.errors.add(:audio_url, :blank)
      end

      respond_with(:api, @broadcast, location: -> { api_callout_path(@broadcast) })
    end

    def show
      respond_with(:api, scope.find(params[:id]))
    end

    private

    def scope
      current_account.broadcasts
    end

    def permitted_params
      params.permit(
        :audio_url,
        :metadata_merge_mode,
        metadata: {},
        settings: {}
      )
    end
  end
end
