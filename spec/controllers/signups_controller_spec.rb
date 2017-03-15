require 'spec_helper'

describe SignupsController do

  describe "POST 'create'" do
    it "renders new template" do
      post 'create'
      response.should render_template :new
    end
  end

end
