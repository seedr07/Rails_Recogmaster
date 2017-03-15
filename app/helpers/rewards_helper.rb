module RewardsHelper
  def link_to_add_reward_card
    new_reward = Reward.new
    id = new_reward.object_id
    form = render("reward_card_form", reward: new_reward)
    link_to("Add Reward", '#', class: "add-reward-card button button-primary", data: {id: id, form: form.gsub("\n", "")})    
  end
end