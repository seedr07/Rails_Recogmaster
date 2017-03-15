class AddDateLoggedInWithSamlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_auth_with_saml_at, :datetime
  end
end
