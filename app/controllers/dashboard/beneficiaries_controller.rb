module Dashboard
  class BeneficiariesController < DashboardController
    def index
      @beneficiaries = scope.page(params[:page]).without_count
    end

    def new
      @beneficiary = scope.new
    end

    def create
      @beneficiary = scope.new(permitted_params)
      @beneficiary.save

      respond_with(:dashboard, @beneficiary)
    end

    def edit
      @beneficiary = scope.find(params[:id])
    end

    def update
      @beneficiary = scope.find(params[:id])
      @beneficiary.update(permitted_params)

      respond_with(:dashboard, @beneficiary)
    end

    def show
      @beneficiary = scope.find(params[:id])
    end

    def destroy
      @beneficiary = scope.find(params[:id])
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
