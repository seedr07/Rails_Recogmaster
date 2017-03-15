class Comment < ActiveRecord::Base

  attr_accessible  :commenter, :content
  belongs_to :commentable, polymorphic: true
  belongs_to :commenter, class_name: "User"
  validates :commenter_id, :commentable_id, :commentable_type, :content, presence: true

  after_create :send_notifications

  def commenter
    User.unscoped { super }
  end

  def post_yammer_recognition_comment!(client)
    if u = self.commenter and u.authenticated_with_yammer?(client)
      
      r = self.commentable
      
      client.create_activity({activity: {
        actor: {name: u.full_name, email:u.email},
        action: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:comment",
        object: {
          type: "#{Recognize::Application.config.credentials["yammer"]["namespace"]}:comment",
          url: r.permalink,
          title: "#{u.full_name} commented on recognition", 
          image: u.avatar_thumb_url,
          description: self.content}},
        message: self.content})
    end
  end

  protected

  def send_notifications
    commentable = self.commentable
    notification_recipients = commentable.flattened_recipients + [commentable.sender] + commentable.comments.collect{|c| c.commenter}
    notification_recipients = notification_recipients.uniq
    notification_recipients.each do |r| 
      next if r == self.commenter
      UserNotifier.delay(queue: 'priority').new_comment(r, self)
    end
  end
  
end
