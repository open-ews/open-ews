module Dashboard
  class BroadcastsController < DashboardController
    def index
      @filter_form = BroadcastFilterForm.new(filter_param)
      @broadcasts = paginate_resources(@filter_form.apply(scope))
    end

    def new
      @broadcast = BroadcastForm.new(account: current_account)
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
      @broadcast = BroadcastForm.new(account: current_account, object: scope.find(params[:id]), **permitted_params)
      @broadcast.save

      respond_with(:dashboard, @broadcast)
    end

    def show
      @broadcast = BroadcastDecorator.new(scope.find(params[:id]))
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

    def permitted_params
      params.require(:broadcast).permit(:audio_file, :channel, beneficiary_groups: [], beneficiary_filter: {})
    end
  end
end
