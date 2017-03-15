class AddTeamIdToRecognitionRecipients < ActiveRecord::Migration
  def change
    add_column :recognition_recipients, :user_id, :integer
    add_column :recognition_recipients, :team_id, :integer
    add_column :recognition_recipients, :company_id, :integer

    remove_column :recognitions, :recipient_id, :integer
    remove_column :recognitions, :recipient_type, :string
    remove_column :recognitions, :recipient_company_id, :integer

    # remove_column :recognition_recipients, :recipient_type
    # remove_column :recognition_recipients, :company_id

    add_index :recognition_recipients, :user_id
    add_index :recognition_recipients, :team_id
    add_index :recognition_recipients, :company_id

    add_index :user_teams, :user_id
    add_index :user_teams, :team_id
    add_index :user_teams, [:user_id, :team_id]
  end
end
