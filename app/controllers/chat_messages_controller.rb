class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    content = params[:content]

    # スレッドIdが設定されていれば既存スレッドを使用
    if params[:chat_thread_id].present?
      @chat_thread = current_user.chat_threads.find(params[:chat_thread_id])
    else
      # なければ仮のtitleで新規スレッド作成
      title = content.truncate(30, omission: "...")
      @chat_thread = current_user.chat_threads.create!(title: title)
    end

    # ユーザーのメッセージを作成
    @chat_thread.chat_messages.create!(
      user: current_user,
      role: "user",
      content: content
    )

    messages = @chat_thread.chat_messages.order(:created_at).pluck(:role, :content).map do |role, message_content|
      { role: role, content: message_content }
    end

    service = Openai::ChatService.new
    response = service.generate_chat_response(messages: messages)
    ai_content = response.dig("choices", 0, "message", "content").to_s.strip
    if ai_content.present?
      @chat_thread.chat_messages.create!(
        user: current_user,
        role: "assistant",
        content: ai_content
      )
    end

    redirect_to chat_thread_path(@chat_thread), notice: "メッセージを送信しました。"
  end
end
