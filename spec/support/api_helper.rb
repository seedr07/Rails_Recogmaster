module ApiHelper

  BASE_PATH = '/api/v2'
  def get(path, params = {}, opts = {} )
    path = BASE_PATH + path if !opts.has_key?(:prefix) || opts[:prefix]
    super(path, params, opts[:headers])
  end

  def post(path, params = {}, opts = {} )
    path = BASE_PATH + path if !opts.has_key?(:prefix) || opts[:prefix]
    super(path, params, opts[:headers])
  end

  def delete(path, params = {}, opts = {})
    path = BASE_PATH + path if !opts.has_key?(:prefix) || opts[:prefix]
    super(path, params, opts[:headers])
  end

  def json_response#(response)
    JSON.parse(response.body)
  end

  shared_context "api_context" do
    let(:client_app) do 
      Doorkeeper::Application.create!(name: "foo", redirect_uri: "urn:ietf:wg:oauth:2.0:oob")
    end

    let(:token) do
      post '/oauth/token', oauth_params, prefix: false
      json_response["access_token"]              
    end

    let(:oauth_params) do
      client_credentials_oauth_params
    end    

    let(:client_credentials_oauth_params) do
        hash = {'grant_type' => 'client_credentials', 
          'client_id' => client_app.uid, 
          'client_secret' => client_app.secret}
          hash['scope'] = scopes if defined?(scopes)
        hash
    end

    let(:password_flow_oauth_params) do
        hash = {'grant_type' => 'password', 
          'client_id' => client_app.uid,
          'username' => user.email, 
          'password' => "abcdef"}
          hash['scope'] = scopes if defined?(scopes)
        hash      
    end

    let(:verb) { :get }
    let(:params) { { } }
    let(:headers) { { } }

    before do
      setup_spec if defined?(setup_spec)
      send(verb, path, params, headers: headers)
    end
  end

  shared_examples "error_response" do |status, code, opts|
    # let(:json) { json_response(response) }
    it "has proper json structure" do
      json = json_response
      opts ||= {}
      expect(json["ok"]).to eq("error"), json.inspect
      expect(json["type"]).to eq("Error")
      expect(response.status).to eq(status)
      expect(json["code"]).to eq(code)
      expect(json["errors"]).to eq(opts[:errors]) if opts[:errors]
    end
  end

  shared_examples "success_response" do |status, type, key, opts|
    it "has proper json structure" do
      opts ||= {}
      json = json_response
      expect(json["ok"]).to eq("success"), json.inspect
      expect(json["type"]).to eq(type)
      expect(response.status).to eq(status)
      expect(json).to have_key(key)
    end
  end

  shared_examples "collection" do |opts|
    it "has proper json structure" do
      opts ||= {}
      json = json_response
      expect(json).to have_key("page")
      expect(json).to have_key("count")
      expect(json).to have_key("total_pages")
      expect(json).to have_key("total_count")
      opts.each do |key, value|
        expect(json[key.to_s]).to eq(value), "json[#{key}] is #{json[key].nil? ? 'nil' : json[key]} but expected #{value}\n#{json}"
      end
    end
  end
end