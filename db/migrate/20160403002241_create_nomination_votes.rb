class CreateNominationVotes < ActiveRecord::Migration
  def change
    create_table :nomination_votes do |t|
      t.belongs_to :nomination, index: true
      t.belongs_to :sender, index: true
      t.belongs_to :sender_company, index: true
      t.text :message
      t.timestamps
    end
  end
end
