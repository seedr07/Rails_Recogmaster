require 'spec_helper'

describe Api::V2::Endpoints::Users do
  include ApiHelper
  include_context "api_context"

  describe 'POST /users' do
    let(:verb) { :post }
    let(:path) { '/users' }
    let(:current_user) { FactoryGirl.create(:active_user) }

    context 'when all parameters are successfully sent' do
      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
      let(:temp_user) { FactoryGirl.build(:active_user) }
      let(:params) { { email: temp_user.email, first_name: temp_user.first_name, last_name: temp_user.last_name} }
      it_behaves_like "success_response", 201, "User", "user"

    end
  end

  describe 'GET /users/search' do
    let(:verb) { :get }
    let(:path) { '/users/search' }
    let(:current_user) { FactoryGirl.create(:active_user) }
    let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => current_user.email, 'X-Auth-Network' => current_user.network} }
    let(:other_user) { FactoryGirl.create(:active_user, email: "asdf@#{current_user.network}") }

    let(:setup_spec) {
      other_user
      current_user.refresh_cached_user_graph!
    }

    context 'when searching by beginning part of last name' do
      let(:params) { { query: other_user.last_name[0..4] } }
      it_behaves_like "success_response", 200, "Collection", "users"

      it "should have other user in the response" do 
        expect(json_response["users"]).to be_present
        expect(json_response["users"].first["email"]).to eq(other_user.email)
        expect(json_response["users"].first["first_name"]).to eq(other_user.first_name)
        expect(json_response["users"].first["last_name"]).to eq(other_user.last_name)
        expect(json_response["users"].first["network"]).to eq(other_user.network)
      end

    end

    context "when searching by beginning part of domain" do
      let(:params) { { query: other_user.network[0..4] } }
      it_behaves_like "success_response", 200, "Collection", "users"

      it "should have other user in the response" do 
        expect(json_response["users"]).to be_present
        expect(json_response["users"].first["email"]).to eq(other_user.email)
        expect(json_response["users"].first["first_name"]).to eq(other_user.first_name)
        expect(json_response["users"].first["last_name"]).to eq(other_user.last_name)
        expect(json_response["users"].first["network"]).to eq(other_user.network)
      end      
    end

  end
end