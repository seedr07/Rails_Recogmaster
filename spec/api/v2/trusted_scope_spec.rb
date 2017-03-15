require 'spec_helper'

describe Api::V2::Endpoints::Users do
  include ApiHelper
  include_context "api_context"

  describe 'POST /users/create_with_network' do
    context 'Untrusted application' do 

      let(:client_app) { FactoryGirl.create(:oauth_application) }
      let(:verb) { :post }
      let(:path) { '/users/create_with_network' }
      let(:current_user) { FactoryGirl.create(:active_user) }

      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
      let(:temp_user) { FactoryGirl.build(:active_user) }
      let(:params) { { email: temp_user.email, first_name: temp_user.first_name, last_name: temp_user.last_name} }
      it_behaves_like "error_response", 403, "forbidden_error", errors:  ["Only trusted applications may use this endpoint"]

    end

    context 'Trusted application' do 

      let(:client_app) { FactoryGirl.create(:trusted_oauth_application) }
      let(:verb) { :post }
      let(:path) { '/users/create_with_network' }
      let(:current_user) { FactoryGirl.create(:active_user) }
      let(:scopes) { "trusted" }
      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
      let(:temp_user) { FactoryGirl.build(:active_user) }
      let(:network) { "foosnazzle.com"}
      let(:params) { { email: temp_user.email, first_name: temp_user.first_name, last_name: temp_user.last_name, network: network } }
      it_behaves_like "success_response", 201, "User", "user"

      it "should have added user into external network" do
        user = User.last
        expect(user.email).to eq(temp_user.email)
        expect(user.network).to eq(network)
        expect(user.company.domain).to eq(network)
      end
    end


  end
end