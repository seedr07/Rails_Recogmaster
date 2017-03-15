class SupportEmailsController < ApplicationController

  def new
    @body = params['body'].present? ? params['body'] : nil
    @support_email = SupportEmail.new
  end

  def sales
    @support_email = SupportEmail.new
  end

  def create
    @support_email = SupportEmail.new(params[:support_email])
    @support_email.save

    if @support_email.persisted?
      case @support_email.message
      when "upgrade"
        flash[:notice] = "Thanks for your interest. We will get back to you shortly about getting started." 
      else
        flash[:notice] = "Success! We've received your inquiry. We'll get back to you shortly." 
      end
    end
    respond_with @support_email, location: contact_path
  end
end