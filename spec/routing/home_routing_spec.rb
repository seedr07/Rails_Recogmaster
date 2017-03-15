require "spec_helper"

describe HomeController do
  describe "routing" do

    it "routes / to signups#index when not logged in" do
      get("/").should route_to("home#index")      
    end

    #TODO: figure out how to use session in routing specs
    # it "routes / to signups#index when logged in" do
    #   # request.session[:user_credentials_id] = FactoryGirl.create(:user).id
    #   get("/").should route_to("recognitions#index")      
    # end
    
  end
end
