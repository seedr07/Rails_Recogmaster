class DataFixForPointTotalsAndBadges < ActiveRecord::Migration
  def up
    #if !Rails.env.test?
    #  # Recognition.where(is_instant: true, badge_id: 33).select{|r| r.sender.company.custom_badges_enabled?}.map{|r| [r.sender.company.custom_badges_enabled?, r.sender.network, r.created_at]}
    #  domains = ["advancio.com", "vigia.com.mx"]
    #  domains.each do |d|
    #    domain = Rails.env.production? ? d : d+".not.real.tld"
    #    c = Company.where(domain: domain).first
    #    if c
    #      recognitions = c.recognitions.where(is_instant: true, badge_id: 33)
    #      new_badge = c.badges.enabled.detect{|b| b.name.to_s.match(/thumbs_up/)}
    #      recognitions.update_all(badge_id: new_badge.id) if new_badge
    #
    #      c.users.each(&:update_total_points!)
    #    end
    #  end
    #end
  end
end
