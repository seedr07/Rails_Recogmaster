require 'spec_helper'

describe Api::V2::Endpoints::Auth do
  include ApiHelper
  include_context "api_context" 
  describe 'POST /auth' do
    let(:client_app) { FactoryGirl.create(:oauth_application)}
    let(:verb) { :post }
    let(:path) { '/auth' }
    let(:user) { FactoryGirl.create(:active_user) }

    context 'when all parameters are successfully sent' do
      let(:params) { { email: user.email, password: "abcdef", client_id: client_app.uid} }

      it_behaves_like "success_response", 201, "AccessToken", "auth"

    end

    context 'when proper credentials but no client id' do
      let(:params) { { email: user.email, password: "ancdef"} }

      it_behaves_like "error_response", 400, "validation_errors", errors:  ["client_id is missing"]
    end

    context 'when improper credentials are sent' do
      let(:params) { { email: user.email, password: "xxxxx", client_id: client_app.uid} }

      it_behaves_like "error_response", 401, "invalid_grant", errors:  ["Access token could not be granted. Please check your credentials."]
    end
  end

  describe 'GET /auth/ping' do
    let(:verb) { :get }
    let(:path) { '/auth/ping' }
    let(:user) { FactoryGirl.create(:active_user) }

    context 'with trusted application' do
      let(:client_app) { FactoryGirl.create(:trusted_oauth_application)}
      let(:scopes) { "profile read write admin trusted" }
      let(:oauth_params) { client_credentials_oauth_params }

      context 'and no token' do
        it_behaves_like "error_response", 401, "invalid_grant", errors:  ["The access token is invalid"]
      end

      context 'and proper token but no X-Auth-Email header' do
        let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
        it_behaves_like "success_response", 200, "AccessToken", "auth"

        it "should not set user" do 
          expect(json_response["auth"]["user"]).to be_nil
        end

      end

      context 'and proper token, proper X-Auth-Email header, but no X-Auth-Network' do
        let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => user.email} }
        it_behaves_like "success_response", 200, "AccessToken", "auth"

        it "should not set user" do 
          expect(json_response["auth"]["user"]).to be_nil
        end

      end

      context 'and proper token and x-auth-email header' do
        let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => user.email, 'X-Auth-Network' => user.network} }
        it_behaves_like "success_response", 200, "AccessToken", "auth"

        it "should set user" do 
          expect(json_response["auth"]["user"]).to be_present
        end

      end
  
    end

    context 'with untrusted application and password grant token' do
      let(:client_app) { FactoryGirl.create(:oauth_application)}
      let(:oauth_params) { password_flow_oauth_params }

      context 'and no token' do
        it_behaves_like "error_response", 401, "invalid_grant", errors:  ["The access token is invalid"]
      end

      context 'and proper token' do
        let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
        it_behaves_like "success_response", 200, "AccessToken", "auth"
      end

    end 

  end
end