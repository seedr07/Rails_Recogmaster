class ChatThread < ActiveRecord::Base
  has_many :chat_messages, inverse_of: :chat_thread

  def new_message
    chat_messages.build
  end
end