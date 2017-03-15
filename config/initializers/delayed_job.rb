require 'delayed_exception'
require 'delayed_duplicate_prevention_plugin'

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 10
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.read_ahead = 10
Delayed::Worker.delay_jobs = Rails.env.production?

Delayed::Worker.logger = Logger.new("log/delayed_job.log", 5, 104857600)

Delayed::Worker.send(:include, DelayedException)
Delayed::Backend::ActiveRecord::Job.send(:include, DelayedException::Backend::ActiveRecord::Job)
Delayed::Backend::ActiveRecord::Job.send(:include, DelayedDuplicatePreventionPlugin::SignatureConcern)
Delayed::Worker.plugins << DelayedException::DelayedExceptionPlugin
Delayed::Worker.plugins << DelayedDuplicatePreventionPlugin

if caller.last =~ /script\/delayed_job/ or (File.basename($0) == "rake" and ARGV[0] =~ /jobs\:work/)
  ActiveRecord::Base.logger = Delayed::Worker.logger
end

