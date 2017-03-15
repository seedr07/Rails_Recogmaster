module IdNameMethods
  extend ActiveSupport::Concern
  DataNotDefinedError = Class.new(StandardError)
  
  included do
    attr_reader :id, :name, :long_name, :opts
  end
  
  def initialize(id, name, long_name, opts={})
    @id = id
    @name = name
    @long_name = long_name
    @opts = opts
  end
  
  def == (other)
    self.class == other.class && self.id == other.id
  end
  
  module ClassMethods
    
    def all
      @all ||= begin
        verify_data_constant
        self::DATA.map { |args| new(*args) }
      end
    end
    
    def find(id)
      all.detect { |instance| instance.id.to_s == id.to_s }
    end
    
    def find_by_name(name)
      all.detect { |instance| instance.name.to_s == name.to_s }      
    end

    def find_by_long_name(name)
      return find_by_name(name.downcase.gsub(" ", "_"))
    end
    
    def name_from_id(id)
      find(id)
        .try(:name)
    end
    
    def id_from_name(name)
      all.detect {|instance| instance.name.to_s == name.to_s}.try(&:id)
    end
    
    def options_for_select
      all
        .map { |e| [e.long_name, e.id] }
    end
    
    private
    
    def verify_data_constant
      unless defined?(self::DATA)
        raise DataNotDefinedError, "You must define a DATA constant"
      end
    end
  end
  
end