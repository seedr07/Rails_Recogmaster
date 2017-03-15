module ActiveRecordTransaction
  extend ActiveSupport::Concern
  
  def transaction
    self.class.transaction do
      yield
    end
  end
  
  module ClassMethods
    
    def transaction
      ActiveRecord::Base.transaction do
        yield
      end
    end
    
  end
  
end