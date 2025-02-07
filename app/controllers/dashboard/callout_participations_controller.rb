module Dashboard
  class CalloutParticipationsController < Dashboard::BaseController
    private

    def association_chain
      if parent_resource
        parent_resource.callout_participations
      else
        current_account.callout_participations
      end
    end

    def parent_resource
      if callout_id
        callout
      elsif callout_population_id
        callout_population
      elsif beneficiary_id
        beneficiary
      end
    end

    def callout_id
      params[:callout_id]
    end

    def callout
      @callout ||= current_account.callouts.find(callout_id)
    end

    def callout_population_id
      params[:batch_operation_id]
    end

    def callout_population
      @callout_population ||= current_account.batch_operations.find(callout_population_id)
    end

    def beneficiary_id
      params[:beneficiary_id]
    end

    def beneficiary
      @beneficiary ||= current_account.beneficiaries.find(beneficiary_id)
    end

    def filter_class
      Filter::Resource::CalloutParticipation
    end
  end
end
