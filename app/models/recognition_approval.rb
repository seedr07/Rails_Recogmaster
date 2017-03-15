class RecognitionApproval < ActiveRecord::Base

  acts_as_paranoid  

  attr_accessible :giver_id, :recognition_id, :giver, :recognition
  belongs_to :giver, :class_name => "User", counter_cache: :given_recognition_approvals_count
  belongs_to :recognition, counter_cache: :approvals_count

  validates :giver_id, :recognition_id, presence: true
  validate :disallow_from_recognition_sender_or_receiver, :disallow_multiple_on_same_recognition

  def post_yammer_activity!(client)
    if u = self.giver and u.authenticated_with_yammer?(client)
      r = self.recognition
      client.create_activity({activity: {
        actor: {name: u.full_name, email:u.email},
        action: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:validation",
        object: {
          type: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:recognition",
          url: r.permalink(include_www: true),
          title: "#{r.recipients_label}'s recognition with the #{r.badge.short_name} badge", 
          image: r.badge_permalink(200, "http:"),
          description: r.message}},
        message: r.message})
    end
  rescue => e
    ExceptionNotifier.notify_exception(e)
  end
    
  protected
  # def disallow_from_users_in_different_company
  #   unless [recognition.sender_company_id, recognition.recipient_company_id].include?(giver.company_id)
  #     errors.add(:base, "You may not plus one a recognition from a different company")
  #   end
  # end
  
  def disallow_from_recognition_sender_or_receiver
    if recognition.participants.include?(giver)
      errors.add(:base, "You may not plus one a recognition that you have sent or received")
    end
  end
  
  def disallow_multiple_on_same_recognition
    if self.class.where(giver_id: giver_id, recognition_id: recognition_id).limit(1).present?
      errors.add(:base, "You may not plus one a recognition more than once")
    end
  end
end
