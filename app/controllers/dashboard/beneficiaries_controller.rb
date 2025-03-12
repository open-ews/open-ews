module Dashboard
  class BeneficiariesController < Dashboard::BaseController
    private

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
      )
    end
  end
end
