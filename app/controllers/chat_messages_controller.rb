class ChatMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    content = message_params[:content]
    chat_thread_id = message_params[:chat_thread_id]

    # スレッドIdが設定されていれば既存スレッドを使用
    if chat_thread_id.present?
      @chat_thread = current_user.chat_threads.find(chat_thread_id)
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

    # Open APIの要求している形式に変換したオブジェクトを取得
    messages = @chat_thread.chat_messages.order(:created_at).pluck(:role, :content).map do |role, message_content|
      { role: role, content: message_content }
    end

    # サービスクラスのインスタンス化
    service = OpenAi::ChatService.new
    response = service.generate_chat_response(messages: messages)
    Rails.logger.info("OpenAI Response: #{response}")

    ai_content = response&.choices&.first&.message&.content.to_s.strip
    if ai_content.present?
      # AIの応答メッセージをDBに保存
      @chat_thread.chat_messages.create!(
        user: current_user,
        role: "assistant",
        content: ai_content
      )
    end

    redirect_to chat_thread_path(@chat_thread), notice: "メッセージを送信しました。"
  end

  def message_params
    params.permit(:content, :chat_thread_id)
  end
end
