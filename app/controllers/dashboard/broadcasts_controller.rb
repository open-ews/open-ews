module Dashboard
  class BroadcastsController < DashboardController
    def index
      @broadcasts = scope.page(params[:page]).without_count
    end

    def new
      @broadcast = BroadcastForm.new
    end

    def create
      @broadcast = BroadcastForm.new(account: current_account, **permitted_params)
      @broadcast.save
      respond_with(:dashboard, @broadcast)
    end

    def edit
      @broadcast = BroadcastForm.initialize_with(scope.find(params[:id]))
    end

    def update
      @broadcast = BroadcastForm.new(object: scope.find(params[:id]), **permitted_params)
      @broadcast.save

      respond_with(:dashboard, @broadcast)
    end

    def show
      @broadcast = scope.find(params[:id])
    end

    def destroy
      @broadcast = scope.find(params[:id])
      @broadcast.destroy
      respond_with(:dashboard, @broadcast)
    end

    private

    def scope
      current_account.broadcasts
    end

    def association_chain
      scope
    end

    def permitted_params
      params.require(:broadcast).permit(:audio_file, :channel, beneficiary_filter: {})
    end
  end
end
