require 'benchmark'
include Benchmark 

sender = User.find(3)
company = sender.company
recipient = User.find(2)
recognition = Recognition.new(sender: sender, badge: company.company_badges.last, recipients: [recipient], message: "test")

puts Benchmark.realtime{ recognition.save }