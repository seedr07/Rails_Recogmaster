class AddSendLimitScopeToCompanyAndBadges < ActiveRecord::Migration
  def change
    add_column :companies, :recognition_limit_scope_id, :integer, default: Recognition::LimitScope.id_from_name(:recognition)
    add_column :companies, :default_recognition_limit_scope_id, :integer, default: Recognition::LimitScope.id_from_name(:recognition)
    add_column :badges, :sending_limit_scope_id, :integer, default: Recognition::LimitScope.id_from_name(:recognition)
  end
end
