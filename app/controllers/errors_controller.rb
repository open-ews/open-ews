class ErrorsController < ApplicationController
  STATUS_CODES = %w[400 404 406 500].freeze

  def show
    @status_code = params[:status_code].to_i

    respond_to do |format|
      format.html { render status: @status_code }
      format.any { head @status_code }
    end
  end
end
