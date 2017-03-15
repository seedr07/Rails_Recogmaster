require 'spec_helper'

describe "home/extension.html.erb" do
  before(:each) do
    view.stub(:current_user).and_return(nil)
    # assign(:user, stub_model(User))#for logged in uses
    assign(:user, User.new)#for logged in uses
  end
  
  it "should have copy and links" do
    render
    rendered.should have_content("Join the thousands of Yammer companies using Recognize")
  end
end