require_dependency File.join(Rails.root, "app/api/user")
module Api
  class Recognition
    include Seahorse::Model

    type :company do
      model ::Company
      integer :id
      string :name
      string :domain
    end

    type :recipient do
      model ::User
      integer :id
      string :email
      string :first_name
      string :last_name
      string :full_name
      string :company_name
      string :avatar_thumb_url
      string :yammer_id
    end

    type :recognition do
      model ::Recognition
      integer :id
      string :message
      string :slug, uri: true
      timestamp :created_at
      string :badge_name
      string :badge_permalink, uri: true
      list(:user_recipients) { recipient }
      list(:approvers) { recipient }
      user :sender
      string :permalink, uri: true
      boolean :system_recognition?
      string :friendly_created_at
      integer :approvals_count

    end

    type :recognition_slimmed do
      model ::Recognition
      integer :approvals_count
      string :slug
    end

    operation :index do
      url '/recognitions'

      input do
        string :yammer_id, uri: true#, required: true
        string :email
        integer :page
      end

      output do
        list(:recognitions) { recognition }
        integer :next_page
      end
    end

    desc 'Returns just the proper url for a recognition form for a particular user'
    operation :new do
      url '/recognitions/new'
      input do
        string :yammer_id, uri: true#, required: true
        string :message
      end

      output do
        string :url, uri: true
      end
    end

    desc 'Sends an instant recognition to the specified yammer user'
    operation :instant do
      verb 'post'
      url '/recognitions/instant'

      input do
        string :yammer_id, required: true
        string :message
        string :yammer_thread_uid
      end

      output do
        recognition :recognition
      end

    end

    desc 'Search recognitions'
    operation :search do
      verb 'get'
      url '/recognitions/search'

      input do
        string :slugs
      end

      output do
        list(:recognitions) { recognition }
        integer :next_page
      end
    end
    
    desc 'Approve/validate/+1 recognition'
    operation :approve do
      verb 'post'
      url '/recognitions/:slug/approvals'

      input do
        string :slug
      end
      
      output :recognition_slimmed
    end

    desc 'Unapprove/unvalidate/remove +1 from recognition'
    operation :unapprove do
      verb 'delete'
      url '/recognitions/:slug/approvals'

      input do
        string :slug
      end
      
      output :recognition_slimmed
    end
    
    
  end
end