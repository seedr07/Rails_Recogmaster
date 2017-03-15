class AddSkillsToRecognition < ActiveRecord::Migration
  def change
    add_column :recognitions, :skills, :text
  end
end
