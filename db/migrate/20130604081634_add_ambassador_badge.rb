class AddAmbassadorBadge < ActiveRecord::Migration
  def up
    # deprecated, this was just a data migration, but on new installs will be handled in init script, will fail due to 
    # requirement for image to be there, but image attribute is added later on
    # Badge.add_to_system!("ambassador")
  end

  def down
    Badge.where(name: "ambassador").first.destroy
  end
end
