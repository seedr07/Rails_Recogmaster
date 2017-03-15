plans = [
    {min_users: 1, max_users: 99, business_amount: 49, enterprise_amount: 199},
    {min_users: 100, max_users: 499, business_amount: 79, enterprise_amount: 299},
    {min_users: 500, max_users: 999, business_amount: 159, enterprise_amount: 599},
    {min_users: 1000, max_users: 4999, business_amount: 299, enterprise_amount: 899},
    {min_users: 5000, max_users: 9999, business_amount: 599, enterprise_amount: 1499},
    {min_users: 10000, max_users: 15000, business_amount: 999, enterprise_amount: 2999},
  ]

def create_plan(plan, type, interval)
  min_users = plan.min_users
  max_users = plan.max_users
  amount = plan.send("#{type}_amount")
  id = "#{type.humanize}#{interval.humanize}ly_#{min_users}_#{max_users}_users"
  name = "#{type.humanize} #{interval.humanize}ly #{min_users}-#{max_users} Users"
  currency = "usd"

  if interval=="year"
    amount *= 0.80 
    amount *= 12
  end

  Stripe::Plan.create(
    id: id,
    amount: (amount*100).to_i,
    interval: interval,
    name: name,
    currency: currency
  )

end

plans = plans.map{|p| Hashie::Mash.new(p)}

plan = plans[0]

plans.each do |plan|
  # business monthly
  create_plan(plan, "business", "month")

  # business yearly
  create_plan(plan, "business", "year")

  # enterprise monthly
  create_plan(plan, "enterprise", "month")

  # enterprise yearly
  create_plan(plan, "enterprise", "year")
end

Plan.sync!