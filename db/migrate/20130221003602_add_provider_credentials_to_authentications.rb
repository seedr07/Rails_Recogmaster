class AddProviderCredentialsToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :credentials, :text
  end
end
