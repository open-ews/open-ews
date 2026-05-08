module Dashboard
  class BeneficiariesController < DashboardController
    def index
      authorize(Beneficiary)
      @filter_form = BeneficiaryFilterForm.new(filter_param)
      @beneficiaries = paginate_resources(@filter_form.apply(scope))
    end

    def new
      @beneficiary = scope.new
      authorize(@beneficiary)
    end

    def create
      @beneficiary = scope.new(permitted_params)
      authorize(@beneficiary)
      @beneficiary.save

      respond_with(:dashboard, @beneficiary)
    end

    def edit
      @beneficiary = scope.find(params[:id])
      authorize(@beneficiary)
    end

    def update
      @beneficiary = scope.find(params[:id])
      authorize(@beneficiary)
      @beneficiary.update(permitted_params)

      respond_with(:dashboard, @beneficiary)
    end

    def show
      @beneficiary = scope.find(params[:id])
      authorize(@beneficiary)
    end

    def destroy
      @beneficiary = scope.find(params[:id])
      authorize(@beneficiary)
      @beneficiary.destroy

      respond_with(:dashboard, @beneficiary)
    end

    private

    def scope
      current_account.beneficiaries
    end

    def permitted_params
      params.require(:beneficiary).permit(
        :phone_number,
        :gender,
        :date_of_birth,
        :disability_status,
        :iso_language_code,
        :iso_country_code,
        group_ids: [],
        addresses_attributes: [
          :id,
          :iso_region_code,
          :administrative_division_level_2_code,
          :administrative_division_level_2_name,
          :administrative_division_level_3_code,
          :administrative_division_level_3_name,
          :administrative_division_level_4_code,
          :administrative_division_level_4_name,
          :_destroy
        ]
      )
    end
  end
end
