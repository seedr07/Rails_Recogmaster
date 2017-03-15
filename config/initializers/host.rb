class Rails::Application::Configuration
  def web_protocol
    local_config["using_ssl"] ? "https://" : "http://"
  end

  def web_host
    web_protocol+host
  end

end