class AddIndexesForRecognitionsAndRecognitionApprovals < ActiveRecord::Migration
  def up
    add_index :recognitions, :badge_id
    add_index :recognitions, :sender_id
    add_index :recognitions, [:recipient_id, :recipient_type]
    add_index :recognition_approvals, :giver_id
    add_index :recognition_approvals, :recognition_id
    add_index :recognition_approvals, [:giver_id, :recognition_id]

    
  end

  def down
    remove_index :recognitions, column: :badge_id
    remove_index :recognitions, column: :sender_id
    remove_index :recognitions, column: [:recipient_id, :recipient_type]
    remove_index :recognition_approvals, column: :giver_id
    remove_index :recognition_approvals, column: :recognition_id
    remove_index :recognition_approvals, column: [:giver_id, :recognition_id]

  end
end
