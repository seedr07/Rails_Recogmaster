class Api::V1::BadgesController < Api::V1::BaseController
  include Seahorse::Controller

  def show
    respond_with Badge.find(params[:id])
  end

  private
end