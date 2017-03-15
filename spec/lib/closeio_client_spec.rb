require 'spec_helper'

describe "CloseIoClient" do 
  describe "contact payload" do
    context "when user signs up via standalone" do
      context "and inputs email" do
        let(:email) { FactoryGirl.generate(:email) }
        let(:user_params) { {email: email } }

        before do
          @user = User.signup!(user_params)          
        end

        it "should set placeholder" do
          payload = Recognize::Application.closeio.contact_payload(@user)
          expect(payload[:name]).to eq(CloseioClient::Extensions::NAME_PLACEHOLDER)
        end
      end

      context "and has existing contact and sets first and last name" do
        let(:email) { FactoryGirl.generate(:email) }
        let(:first_name) { "Bob" }
        let(:last_name) { "Vila" }
        let(:user_params) { {email: email, first_name: first_name, last_name: last_name} }

        before do
          @user = User.signup!(user_params)          
        end

        it "should overwrite placeholder with name" do
          # stub out closeio contact
          closeio_contact = Hashie::Mash.new(name: CloseioClient::Extensions::NAME_PLACEHOLDER)
          payload = Recognize::Application.closeio.contact_payload(@user, closeio_contact)
          expect(payload[:name]).to eq("#{first_name} #{last_name}")          
        end
      end

    end

    context "when user signs up via yammer" do
      let(:email) { FactoryGirl.generate(:email) }
      let(:first_name) { "Bob" }
      let(:last_name) { "Vila" }
      let(:user_params) { {email: email, first_name: first_name, last_name: last_name} }
 
      before do
        @user = User.signup!(user_params)
      end

      it "should set first and last name" do
        payload = Recognize::Application.closeio.contact_payload(@user)
        expect(payload[:name]).to eq("#{first_name} #{last_name}")
      end
    end
  end
end