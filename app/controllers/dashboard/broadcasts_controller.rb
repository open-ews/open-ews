module Dashboard
  class BroadcastsController < DashboardController
    def index
      authorize(Broadcast)
      @filter_form = BroadcastFilterForm.new(filter_param)
      @broadcasts = paginate_resources(@filter_form.apply(scope))
    end

    def new
      authorize(Broadcast)
      @broadcast = BroadcastForm.new(account: current_account)
    end

    def create
      authorize(Broadcast)
      @broadcast = BroadcastForm.new(account: current_account, created_by: current_user, **permitted_params)
      @broadcast.save
      respond_with(:dashboard, @broadcast)
    end

    def edit
      @broadcast = BroadcastForm.initialize_with(scope.find(params[:id]))
      authorize(@broadcast.object)
    end

    def update
      @broadcast = BroadcastForm.initialize_with(scope.find(params[:id]))
      authorize(@broadcast.object)
      @broadcast.assign_attributes(updated_by: current_user, **permitted_params)
      @broadcast.save

      respond_with(:dashboard, @broadcast)
    end

    def show
      @broadcast = BroadcastDecorator.new(scope.find(params[:id]))
      authorize(@broadcast.object)
    end

    def destroy
      @broadcast = scope.find(params[:id])
      authorize(@broadcast)
      @broadcast.destroy
      respond_with(:dashboard, @broadcast)
    end

    private

    def scope
      current_account.broadcasts
    end

    def permitted_params
      params.require(:broadcast).permit(
        :name,
        :audio_file,
        :message,
        :channel,
        beneficiary_groups: [],
        beneficiary_filter: {}
      )
    end
  end
end
