class ChatMessagesController < ApplicationController

  def create
    @chat_message_creator = ChatMessageCreator.new(params[:chat_message])
    @chat_message_creator.save

    @chat_message = @chat_message_creator.chat_message

    render json: @chat_message
  end

  def index
  end

  def show
  end

  protected

  def current_thread
    @chat_thread ||= ChatThread.new
  end


end