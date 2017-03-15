class AddSlugToCompany < ActiveRecord::Migration
  def up
    add_column :companies, :domain, :string
    add_column :companies, :slug, :string
    remove_column :companies, :subdomain
    Company.with_deleted.find_by_name("Recognize Inc.").update_attribute(:slug, :recognize) if Company.with_deleted.exists?(name: "Recognize Inc.")
  end
  
  def down
    add_column :companies, :subdomain, :string
    remove_column :companies, :slug
    remove_column :companies, :domain
  end
end
