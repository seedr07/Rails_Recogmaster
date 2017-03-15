set :output, "#{path}/log/cron_log.log"

# every 1.hour do
#   command "#{path}/script/delayed_job_monitor"
# end
# 
every 1.day, at: "6:00 AM" do
  runner "Reminder::Process.daily"
end

every 1.day, at: "7:00 AM" do
  script "delayed_job restart"
end

every :saturday, at: "2:00 AM" do
  rake "recognize:backup_and_upload"
end

every 1.day, at: "1:00 AM" do
  runner "Company.analytics_data.refresh!;puts Company.analytics_data"
end

every 1.day, at: "12:00AM" do
  runner "Points::Resetter.run_scheduler"
end

every 30.minutes do
  runner "Report::CacheManager::Company.bust_and_reprime_all_report_caches_if_necessary!"
end

every 1.day, at: "8:00AM" do
  runner "YearsOfService.notify_all_anniversaries"
  runner "NewCompanyAdminDigest.send!"
end



every 1.day, at: "5:00AM" do
  rake 'recognize:generate_daily_sample_data'
end
# every 1.day, at: "9:00AM" do
#   runner "IntervalNotifier.run_scheduler"
# end
