class AddThemeOptionToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :has_theme, :boolean, :default => false
  end
end