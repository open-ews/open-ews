module Dashboard
  class BeneficiaryGroupsController < DashboardController
    def index
      @beneficiary_groups = paginate_resources(scope)
    end

    def new
      @beneficiary_group = scope.new
    end

    def create
      @beneficiary_group = scope.new(permitted_params)
      @beneficiary_group.save

      respond_with(:dashboard, @beneficiary_group)
    end

    def edit
      @beneficiary_group = scope.find(params[:id])
    end

    def update
      @beneficiary_group = scope.find(params[:id])
      @beneficiary_group.update(permitted_params)

      respond_with(:dashboard, @beneficiary_group)
    end

    def show
      @beneficiary_group = scope.find(params[:id])
    end

    def destroy
      @beneficiary_group = scope.find(params[:id])
      @beneficiary_group.destroy

      respond_with(:dashboard, @beneficiary_group)
    end

    private

    def scope
      current_account.beneficiary_groups
    end

    def permitted_params
      params.require(:beneficiary_group).permit(:name)
    end
  end
end
