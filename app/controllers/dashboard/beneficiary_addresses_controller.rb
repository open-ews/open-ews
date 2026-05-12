module Dashboard
  class BeneficiaryAddressesController < DashboardController
    def new
      authorize(BeneficiaryAddress)
    end
  end
end
