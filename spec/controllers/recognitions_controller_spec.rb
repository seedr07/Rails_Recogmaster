require 'spec_helper'

describe RecognitionsController do
    
  def valid_attributes
    attrs = FactoryGirl.attributes_for(:recognition, :sender_id => current_user.id)
    rset = attrs.delete(:recipients)
    attrs[:recipient_emails] = rset.collect{|r| r.email}
    attrs
  end
    
  before(:each) do
    @user = login(:active_user)
  end
  
  describe "GET index" do
    it "assigns all recognitions as @recognitions" do
      existing_recognitions = current_user.recognitions
      existing_recognitions.inspect#need to trigger the lazy loading, now!
      recognition = Recognition.create! valid_attributes
      get :index, {network: @user.network}
      assigns(:recognitions).to_set.should eq(([recognition]+existing_recognitions).to_set)
    end
  end

  describe "GET show" do
    it "assigns the requested recognition as @recognition" do
      recognition = Recognition.create! valid_attributes
      get :show, {network: @user.network, :id => recognition.to_param}
      assigns(:recognition).should eq(recognition)
    end
  end

  describe "GET new" do
    it "assigns a new recognition as @recognition" do
      get :new, {network: @user.network}
      assigns(:recognition).should be_a_new(Recognition)
    end
  end

  describe "GET edit" do
    it "assigns the requested recognition as @recognition" do
      recognition = FactoryGirl.create(:recognition, sender: @user, recipients: FactoryGirl.create(:active_user, email: "anotheremail@"+@user.company.domain))
      get :edit, {network: @user.network, :id => recognition.to_param}
      assigns(:recognition).should eq(recognition)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Recognition" do
        attrs = valid_attributes
        expect {
          post :create, {network: @user.network,:recognition => attrs}
        }.to change(Recognition, :count).by(1)
      end

      it "assigns a newly created recognition as @recognition" do
        post :create, {network: @user.network, :recognition => valid_attributes}
        assigns(:recognition).should be_a(Recognition)
        assigns(:recognition).should be_persisted
      end

      it "redirects to the created recognition" do
        post :create, {network: @user.network, :recognition => valid_attributes}
        response.should redirect_to(recognition_path(assigns(:recognition)))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved recognition as @recognition" do
        # Trigger the behavior that occurs when invalid params are submitted
        Recognition.any_instance.stub(:save).and_return(false)
        post :create, {network: @user.network, :recognition => {:foo => "abc"}}
        assigns(:recognition).should be_a_new(Recognition)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        # Recognition.any_instance.stub(:save).and_return(false)
        post :create, {network: @user.network, :recognition => {:foo => "abc"}}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      # it "does not allow update of the requested recognition" do
      #   recognition = Recognition.create! valid_attributes
      #   # Assuming there are no other recognitions in the database, this
      #   # specifies that the Recognition created on the previous line
      #   # receives the :update_attributes message with whatever params are
      #   # submitted in the request.
      #   # Recognition.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
      #   expect{
      #   put :update, {:id => recognition.to_param, :recognition => {'these' => 'params'}}
      #   }.to raise_error(AbstractController::ActionNotFound)
      # end
      before do
        @recipient = FactoryGirl.create(:active_user, email: "emailwhatever@#{@user.company.domain}")
        @recognition = FactoryGirl.create(:recognition, sender: @user, recipients: @recipient)
        @params = {network: @user.network, :id => @recognition.to_param, :recognition => {'message' => 'Brand new message'}}
        put :update, @params
      end

      it "assigns a newly created recognition as @recognition" do
        assigns(:recognition).should be_a(Recognition)
        assigns(:recognition).should be_persisted
        @recognition.reload.message.should == @params[:recognition]['message']
      end

      it "redirects to the created recognition" do
        post :create, {network: @user.network, :recognition => valid_attributes}
        response.should redirect_to(recognition_path(assigns(:recognition)))
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested recognition" do
      recognition = Recognition.create! valid_attributes
      expect {
        delete :destroy, {network: @user.network, :id => recognition.to_param}
      }.to change(Recognition, :count).by(-1)
    end

    it "redirects to the recognitions list" do
      recognition = Recognition.create! valid_attributes
      delete :destroy, {network: @user.network, :id => recognition.to_param}
      response.should redirect_to(recognitions_url)
    end
  end

end
