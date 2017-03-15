module RspecHelper
  def associations(model, type)
    model.class.reflect_on_all_associations(type).map(&:name) 
  end

  def error_str(options={})
    msg =    %(expected #{transform(options[:expected])})
    msg << %(\n     got #{transform(options[:got])}) if options[:got]
    msg << %(\n  actual #{transform(options[:actual])}) if options[:actual]
    msg << %(\n)
    msg    
  end
  
  def transform(args)
    sprintf(*args)
  end
end