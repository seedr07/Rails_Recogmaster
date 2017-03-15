# only monkey patch if necessary
if Recognize::Application.config.local_config.has_key?("debug")
  module ApplicationHelper
    def url_for(options={})
     options = case options
      when String
        if options.match(/debug/)
          options
        else
          options + (options.index('?').nil? ? '?' : '&') + 'debug=true'
        end
      when Hash
        options.reverse_merge(debug: true)
      else
        options
      end
      super    
    end    
  end
end