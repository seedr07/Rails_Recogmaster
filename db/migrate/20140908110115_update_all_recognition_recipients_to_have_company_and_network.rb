class UpdateAllRecognitionRecipientsToHaveCompanyAndNetwork < ActiveRecord::Migration
  def up
    User.unscoped do 
      Team.unscoped do 
        # cant eager load here due to paranoid check unscoping not working
        set = RecognitionRecipient.all
        failed = []
        
          set.each_with_index do |rr, i|
            puts "Migrating #{i}/#{set.length}"
            if rr.recipient.present?
              rr.send(:set_recipient_company)
              rr.save!
            else
              failed << rr
            end
          end

        if failed.length > 0
          puts "Failed migrating: #{failed.length}"
          binding.pry
          puts ""
        end
      end
    end
  end
end
