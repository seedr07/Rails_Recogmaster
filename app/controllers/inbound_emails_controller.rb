class InboundEmailsController < ApplicationController
  def create
    @inbound_emails = mandrill_events.map{|event_hash| InboundEmail.create!(data: event_hash) }
    render nothing: true, status: 200
  end

  private
  def mandrill_events
    JSON.parse(params[:mandrill_events])
  end
end