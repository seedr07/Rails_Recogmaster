class CreateCampaignsForNominations < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.belongs_to :badge, index: true
      t.belongs_to :company, index: true
      t.boolean :is_archived, default: false, index: true
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
