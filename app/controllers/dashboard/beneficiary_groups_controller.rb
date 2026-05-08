module Dashboard
  class BeneficiaryGroupsController < DashboardController
    def index
      authorize(BeneficiaryGroup)
      @filter_form = BeneficiaryGroupFilterForm.new(filter_param)
      @beneficiary_groups = paginate_resources(@filter_form.apply(scope))
    end

    def new
      @beneficiary_group = scope.new
      authorize(@beneficiary_group)
    end

    def create
      @beneficiary_group = scope.new(permitted_params)
      authorize(@beneficiary_group)
      @beneficiary_group.save

      respond_with(:dashboard, @beneficiary_group)
    end

    def edit
      @beneficiary_group = scope.find(params[:id])
      authorize(@beneficiary_group)
    end

    def update
      @beneficiary_group = scope.find(params[:id])
      authorize(@beneficiary_group)
      @beneficiary_group.update(permitted_params)

      respond_with(:dashboard, @beneficiary_group)
    end

    def show
      @beneficiary_group = scope.find(params[:id])
      authorize(@beneficiary_group)
    end

    def destroy
      @beneficiary_group = scope.find(params[:id])
      authorize(@beneficiary_group)
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
