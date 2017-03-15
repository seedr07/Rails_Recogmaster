require 'delayed_job'

module DelayedException
  FORMAT = "%FT%T%:z"

  def self.included(base)
    base.class_eval do
      alias_method_chain :handle_failed_job, :exception
    end
  end

  def self.notify(exception, job)
    data = {time: Time.now, job: job.inspect}    
    payload = job.payload_object rescue nil

    if payload
      data[:object] = payload.object.respond_to?(:id) ? "#{payload.object.class}:#{payload.object.id}" : payload.object.class
      data[:method_name] = payload.method_name
      data[:args] = payload.args
    end
    ExceptionNotifier.notify_exception(exception, data: data)          
  end
  
  def handle_failed_job_with_exception(job, error)
    begin
      handle_failed_job_without_exception(job, error)
    rescue Exception => e
      Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:handle_failed_job)(fatal)(#{job.id}-#{job.attempts}): #{error.message}"
      DelayedException.notify(e, job)
      # reschedule(job)
      failed(job)
    end
  end

  module Backend
    module ActiveRecord
      module Job
        def destroy_failed_jobs?
          false
        end

        def payload_object
          super
        rescue Psych::SyntaxError => e
          msg = "Delayed::Job Psych Syntax Error - Job(#{self.id}) - Job failed to load: #{e.message}. Handler: #{handler.inspect}"
          Delayed::Worker.logger.error msg
          raise Delayed::DeserializationError, msg
        end

      end
    end
  end
    
  class DelayedExceptionPlugin < Delayed::Plugin
  
    callbacks do |lifecycle|
      lifecycle.around(:loop) do |worker, *args, &block|
        begin
          block.call(worker, *args)
        rescue ActiveRecord::StatementInvalid => error
          if error.message.starts_with?("Mysql2::Error: Lock wait timeout exceeded; try restarting transaction")
            Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:loop)(retrying): #{error.message}"
            retry
          else
            Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:loop)(fatal): #{error.message}"
            ExceptionNotifier.notify_exception(error, data: {time: Time.now, worker: worker, args: args})
            raise error
          end
        rescue Delayed::DeserializationError => error
            Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION Delayed::DeserializationError #{error.message}"
            ExceptionNotifier.notify_exception(error, data: {time: Time.now, worker: worker, args: args})
          raise error unless error.message.match(/^ActiveRecord::RecordNotFound/)

        rescue Exception => error
          Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:loop)(fatal): #{error.message}"
          ExceptionNotifier.notify_exception(error, data: {time: Time.now, worker: worker, args: args})
          raise error
        end
      end
    
      lifecycle.around(:invoke_job) do |job, *args, &block|
        begin
          block.call(job, *args)
        rescue Exception => error
          Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:invoke_job)(fatal): #{error.message}"
          DelayedException.notify(error, job)            
          raise error
        end
      end

      lifecycle.around(:error) do |job, *args, &block|
        begin
          block.call(job, *args)
        rescue Exception => error
          Delayed::Worker.logger.warn "#{Time.now.strftime(FORMAT)}: EXCEPTION DelayedJob(:error)(fatal): #{error.message}"
          DelayedException.notify(error, job)            
          raise error
        end
      end

    end
  
  end

end
 

