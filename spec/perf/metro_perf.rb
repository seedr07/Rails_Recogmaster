# bin/rails r spec/perf/metro_perf.rb
# Orig: 25.700249
# >total:  20.660000   2.450000  23.110000 ( 28.997560)
# >avg:     0.014652   0.001738   0.016390 (  0.020566)
require 'benchmark'
include Benchmark 

c = Company.where(domain: "metrobank.plc.uk.not.real.tld").first
u = c.users.second #bruce
$start_date = u.interval_start_date
$end_date = u.interval_end_date
report = Report::Company.new(u.company, $start_date, $end_date)
puts Benchmark.realtime{report.send(:leaders)}
# puts Benchmark.realtime{report.leaderboard_relative_to(u, :points, 10)}


############################################################################
# n = 50000
# reports = []

# def do_report(user)
#   user_report = Report::User.new(user, $start_date, $end_date)
#   hash = {}
#   hash[user.id] = {
#     id: user.id,
#     user: user, 
#     sent_recognitions: user_report.sent_recognitions.size,
#     received_recognitions: user_report.received_recognitions.size,
#     sent_approvals: user_report.sent_approvals.size,
#     received_approvals: user_report.received_approval_count,
#     points: user_report.points
#   }
#   hash  
# end

# Benchmark.benchmark(CAPTION, 7, FORMAT, ">total:", ">avg:") do |x|
#   # tf = x.report("for:")   { for i in 1..n; a = "1"; end }
#   # tt = x.report("times:") { n.times do   ; a = "1"; end }
#   # tu = x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
#   # [tf+tt+tu, (tf+tt+tu)/3]
#   c.users.each do |user|
#     reports << x.report("User:#{user.id}(#{user.email})") { do_report(user) }
#   end

#   [reports.sum, (reports.sum / reports.length)]
# end
############################################################################
