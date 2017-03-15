class ChatMessageCreator
  attr_reader :params, :chat_message, :chat_thread

  def initialize(params)
    @params = params
  end

  def save
    if chat_thread_id.present?
      create_message_for_existing_thread
    else
      create_message_for_new_thread
    end
  end

  private
  def chat_thread_id
    @chat_thread_id ||= params[:chat_thread_attributes] && params[:chat_thread_attributes].delete(:id)
  end

  def create_message_for_existing_thread
    @chat_thread = ChatThread.find(chat_thread_id)
    @chat_message = @chat_thread.chat_messages.create(params)
  end

  def create_message_for_new_thread
    @chat_thread = ChatThread.new
    @chat_thread.chat_messages.build(params)
    @chat_thread.save
    @chat_message = @chat_thread.chat_messages.first
  end
end