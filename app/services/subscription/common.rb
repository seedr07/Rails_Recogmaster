module Subscription::Common
  extend ActiveSupport::Concern

  included do
    include ActiveRecordTransaction
    attr_reader :skip_signature_validation
  end

  def initialize(company, user, params)
    @company = company
    @user = user
    @params = params
    @skip_signature_validation = params.delete(:skip_signature_validation)
  end
    
  def format_billing_start_date(params)
    if params[:billing_start_date].present?
      params[:billing_start_date] = Date.strptime(params[:billing_start_date], "%m/%d/%Y")
    end
  end

  def before_save
    @subscription.skip_signature_validation = skip_signature_validation
  end
end