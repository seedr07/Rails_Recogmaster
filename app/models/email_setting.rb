class EmailSetting < ActiveRecord::Base
  acts_as_paranoid
  
  SETTINGS = [:new_recognition, :new_comment, :daily_updates, :weekly_updates, :monthly_updates, :activity_reminders, :interval_winner_notifications, :allow_sms_notifications]
  attr_accessible *SETTINGS
  attr_accessible :global_unsubscribe

  # this used to work on create too, but stopped when upgraded to v4.1.10
  # try to check again later
  validates :user_id, presence: true, on: :update 
  validates *([:global_unsubscribe]+SETTINGS+[inclusion: {in: [true, false]}])
  
  belongs_to :user, inverse_of: :email_setting
  
  def self.settings
    return SETTINGS
  end

  def unsubscribe!
    update_attribute(:global_unsubscribe, true)
  end
end
