class ChatThreadsController < ApplicationController

  def index
    @threads = ChatThread.all

    respond_to do |format|
      format.html
      format.json  { render json: @threads }
    end
  end

  def show
    @thread = ChatThread.find(params[:id])
  end
end
