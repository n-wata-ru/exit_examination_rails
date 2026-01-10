class AiChatsController  < ApplicationController
  before_action :authenticate_user!

  def show
    # ユーザーのチャットスレッドを取得
    @threads = ChatThread.where(user: current_user)
    # スレッド表示用
    @messages = ChatMessage.order(:created_at).where(chat_thread: @threads)
  end

  def create
    # ユーザーからのメッセージを受け取り、AIに送信して応答を取得する処理
    # ここでAIサービスとの連携を行い、応答を取得する（例: OpenAI APIなど）
  end
end
