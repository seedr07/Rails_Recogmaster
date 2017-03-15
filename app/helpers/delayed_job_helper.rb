module DelayedJobHelper
  def dj_method_name(job)
    job.handler.match(/method_name:(.*)\n/)[1].gsub(':','').strip
  rescue => e
    e.to_s
  end

  def dj_object_label(job)
    klass_or_obj = job.handler.match(/Performable.*\nobject:(.*)\n/)[1]
    if klass_or_obj.match(/ruby\/class/)
      klass = klass_or_obj.gsub('!ruby/class ', '').gsub('\'','').strip
    else
      klass = klass_or_obj.gsub('!ruby/object:', '').gsub('\'','').strip
      id_attr = job.handler.match(/attributes:\n(.*)\n/)
      id = id_attr ? id_attr[1].strip.split(":")[1].strip : nil
    end
    return id ? "#{klass}:#{id}" : klass
  rescue => e
    e.to_s
  end

  def dj_args(job)
    job.handler.match(/args:(.*)\n/m)[1].strip
  rescue => e
    e.to_s
  end

  def dj_queue(job)
    job.queue
  end
end