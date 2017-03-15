module LocalConfig
  class Base
    def load_config(f=Rails.root.to_s+'/config/local.yml')
      unless File.exists?(f)
        f = f+".sample"
      end
      @local_config = YAML.load(ERB.new(File.new(f).read).result)
      return self
    end
  
    def apply_config_to_rails
      Rails.configuration.local_config = @local_config
    end
  
    def update_config(config)
      overrides = @local_config["override"] || []
      while(opts = overrides.shift)
       k, v = opts[0], opts[1]
       keys = k.split(".")
       param = keys.pop
       obj = keys.inject(config){|memo, key| memo.send(key)}
       obj.send("#{param}=", v)
      end
      
      global_overrides = @local_config["global"] || []
      while(opts = global_overrides.shift)
        k, v = opts[0], opts[1]
        keys = k.split(".")

        obj=keys.shift.constantize
        while(m = keys.shift)
          if keys.length > 0
            obj = obj.send(m)
          else
            obj.send("#{m}=", v)
          end
        end

      end
    end
  end
  
  def self.apply_local_configs(rails_config)
    local_config = Base.new.load_config
    local_config.apply_config_to_rails
    local_config.update_config(rails_config)
  end
end