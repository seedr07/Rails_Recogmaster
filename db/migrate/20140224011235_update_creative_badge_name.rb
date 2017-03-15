class UpdateCreativeBadgeName < ActiveRecord::Migration
  def up
    if Badge.count > 0
      Badge.where(name: 'creative').first.update_attribute(:disabled_at, Time.now)
      Badge.add_to_system!("skilled")
    end
  end

  def down
    Badge.where(name: "skilled").destroy_all
  end
end
