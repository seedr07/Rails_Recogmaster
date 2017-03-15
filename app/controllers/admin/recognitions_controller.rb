class Admin::RecognitionsController < Admin::BaseController

  def index
    @recognitions = Recognition.includes({:sender => :company}, :badge, :recognition_recipients => {:user => :company}).paginate(page: params[:page], per_page: 100)
  end

end