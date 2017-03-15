class SocialShare
  attr_reader :url
  @@map = {
    twitter: ->(url, title, summary) { "https://twitter.com/home?status=#{title}: #{url}"},
    facebook: ->(url, title, summary) { "http://www.facebook.com/sharer.php?t=#{title}&u=#{url}"},
    googleplus: ->(url, title, summary) { "https://plus.google.com/share?url=#{url}&t=#{title}"},
    linkedin: ->(url, title, summary) { "http://www.linkedin.com/shareArticle?mini=true&url=#{url}&title=#{title}&summary=#{summary}&source=Recognize"}
  }
  def initialize(provider, title, url, summary="")
    @provider, @title, @share_url, @summary = provider.to_sym, title, url, summary
    @url = generate_url
  end
    
  def generate_url
    @@map[@provider].call(@share_url, @title, @summary)
  end
end