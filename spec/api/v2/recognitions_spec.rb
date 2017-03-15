require 'spec_helper'

describe Api::V2::Endpoints::Recognitions do
  include ApiHelper
  include_context "api_context"

  describe 'GET /recognitions' do
    let(:verb) { :get }
    let(:path) { '/recognitions' }

    context 'when no token' do
      errors = ["The access token is invalid"] 
      it_behaves_like "error_response", 401, "invalid_grant", errors: errors
    end

    context 'when application token but no X-Auth-Email header' do
      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}"} }
      errors = ["X-Auth-Email or X-Auth-Network header is missing."]
      it_behaves_like "error_response", 401, "invalid_grant", errors: errors
    end

    context 'when valid authentication headers' do
      let(:user) { FactoryGirl.create(:active_user) }
      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => user.email, 'X-Auth-Network' => user.network} }
      
      it_behaves_like "success_response", 200, "Collection", "recognitions"
      it_behaves_like "collection", total_pages: 1, total_count: 1

      it "returns recognitions" do
        expect(json_response["recognitions"].length).to eq(1)
        expect(json_response["recognitions"][0]["id"]).to eq(Recognition.last.slug)
      end
    end
  end

  describe 'POST /recognitions' do
    let(:verb) { :post }
    let(:path) { '/recognitions' }
    let(:current_user) { FactoryGirl.create(:active_user) }

    context 'when all parameters are successfully sent' do
      let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => current_user.email, 'X-Auth-Network' => current_user.network} }
      let(:params) { { recipients: FactoryGirl.generate(:email), badge: "Brilliant", message: "Congrats on the product launch"} }
      it_behaves_like "success_response", 201, "Recognition", "recognition"

    end
  end

  describe 'GET /recognitions/:id' do
    let(:verb) { :get }
    let(:current_user) { FactoryGirl.create(:active_user) }
    let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => current_user.email, 'X-Auth-Network' => current_user.network} }

    context "when recognition exists" do
      let(:recognition) { FactoryGirl.create(:recognition, sender: current_user) }
      let(:path) { "/recognitions/#{recognition.recognize_hashid}" }

      it_behaves_like "success_response", 200, "Recognition", "recognition"

      it "should return recognition" do
        expect(json_response["recognition"]["id"]).to eq(recognition.recognize_hashid)
      end
    end

    context "when recognition does not exist" do
      let(:path) { "/recognitions/xxx" }

      it_behaves_like "error_response", 404, "record_not_found"
    end

    context "when user does not have permission to view" do
      let(:recognition) { FactoryGirl.create(:recognition) }
      let(:path) { "/recognitions/#{recognition.recognize_hashid}" }

      it_behaves_like "error_response", 401, "unauthorized"

    end
  end

  describe 'DELETE /recognitions/:id' do
    let(:verb) { :delete }
    let(:current_user) { FactoryGirl.create(:active_user) }
    let(:headers) { {'HTTP_AUTHORIZATION' => "Bearer #{token}", 'X-Auth-Email' => current_user.email, 'X-Auth-Network' => current_user.network} }

    context "when recognition exists" do
      let(:recognition) { FactoryGirl.create(:recognition, sender: current_user) }
      let(:path) { "/recognitions/#{recognition.recognize_hashid}" }

      it_behaves_like "success_response", 200, "Recognition", "recognition"

      it "should return recognition" do
        expect(json_response["recognition"]["id"]).to eq(recognition.recognize_hashid)
      end
    end

    context "when recognition does not exist" do
      let(:path) { "/recognitions/xxx" }

      it_behaves_like "error_response", 404, "record_not_found"
    end

    context "when user does not have permission to view" do
      let(:recognition) { FactoryGirl.create(:recognition) }
      let(:path) { "/recognitions/#{recognition.recognize_hashid}" }

      it_behaves_like "error_response", 401, "unauthorized"

    end
  end
end
