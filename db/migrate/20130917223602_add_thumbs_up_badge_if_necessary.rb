class AddThumbsUpBadgeIfNecessary < ActiveRecord::Migration
  def up
    # deprecated, this was just a data migration, but on new installs will be handled in init script, will fail due to 
    # requirement for image to be there, but image attribute is added later on
    # Badge.add_to_system!("thumbs_up") unless Badge.exists?(name: "thumbs_up")
  end

  def down
  end
end
