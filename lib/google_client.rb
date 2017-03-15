class GoogleClient
  attr_accessor :token

  ENDPOINT = "https://www.google.com/m8/feeds/contacts/"
  GPLUS_ENDPOINT = "https://www.googleapis.com/plus/v1/people/"
  
  def initialize(token)
    @token = token
  end

  def get_contacts_emails(query=nil, max_results=nil)
    set = {}
    contacts = get_contacts(query, max_results)

    if contacts["feed"]["entry"].respond_to?(:each)
      contacts["feed"]["entry"].each do |e| 
        next unless e && e.kind_of?(Hash)
        if e["email"].present?
          if e["email"].kind_of?(Array)
            e["email"].each{|a| set[a["address"]] = e["title"]}
          else
            set[e["email"]["address"]] = e["title"]
          end
        end
      end
    end
    return set
  end

  def get_contacts(query=nil, max_results=nil)
    max_results = 10000000 if max_results.nil?
    url = "#{ENDPOINT}default/full/?max-results=#{max_results}"
    url += "&q=#{query}" if query.present?
    
    response = request(url)
    #response.to_xml
    
    return Hash.from_xml(response.body)
  end
  
  def get_user(id)
    url = "#{GPLUS_ENDPOINT}#{id}"
    response = request(url)
    return JSON.parse(response.body)
  end

  def request(url)
    r = GData::HTTP::Request.new(url, headers: {"GData-Version" => "3.0", "Authorization" => "Bearer #{token}"})    
    response = GData::HTTP::DefaultService.new.make_request(r)
  end

end