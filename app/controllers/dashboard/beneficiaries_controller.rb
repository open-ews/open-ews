module Dashboard
  class BeneficiariesController < Dashboard::BaseController
    def create
      @resource = scope.new(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    private

    def scope
      current_account.beneficiaries
    end

    def association_chain
      current_account.beneficiaries
    end

    def build_key_value_fields
      build_metadata_field
    end

    def permitted_params
      params.fetch(:beneficiary, {}).permit(
        :phone_number,
        :gender,
        :date_of_birth,
        :disability_status,
        :language_code,
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
