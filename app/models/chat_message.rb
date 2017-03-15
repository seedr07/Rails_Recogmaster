class ChatMessage < ActiveRecord::Base
  belongs_to :chat_thread, inverse_of: :chat_messages, autosave: true

  accepts_nested_attributes_for :chat_thread
  before_create :stash_email_on_thread

  private

  def stash_email_on_thread
    if body_contains_email?
      self.chat_thread.update_column(:email, email_from_body)
    end
  end

  def body_contains_email?
    body.match(/\@/)
  end

  def email_from_body
    body.split(" ").detect{|b| b.match(/\@/)}
  end
end
