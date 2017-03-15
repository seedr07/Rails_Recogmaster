module RedemptionsHelper
  def reward_availability_status(reward, user)
    if !reward.can_redeem_within_frequency?(user)
      "unredeemable unredeemable-by-frequency"
    elsif !reward.can_redeem_by_points?(user)
      "unredeemable unredeemable-by-points"
    else 
      return "redeemable"
    end
  end

  def redemption_points_needed(reward, user)
    -(user.redeemable_points - reward.points)
  end
end